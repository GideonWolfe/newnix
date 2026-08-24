{ inputs, lib, config, ... }:

# Hermes Agent gateway -- the agent/orchestration layer that sits ABOVE the
# inference stack. It's a single persistent process you talk to from many
# surfaces (CLI, and later Telegram/Signal/etc.), not a per-client install.
# It calls the local llama-swap OpenAI endpoint for inference and owns the
# durable agent state: skills, memory, sessions.
#
# The upstream module (services.hermes-agent) is imported here so this module
# is self-contained -- importing ./hermes brings both the upstream module and
# its configuration together (same pattern as sops.nix / stylix.nix). It runs
# `hermes gateway` as a native systemd service and lays out HERMES_HOME for us.
#
# Storage: HERMES_HOME lives on the VM's LOCAL disk (stateDir default
# /var/lib/hermes -> HERMES_HOME /var/lib/hermes/.hermes). This is deliberate:
#   - Hermes keeps its state in SQLite (sessions + FTS search index); SQLite
#     over NFS is flaky, so the live DB must be on local disk, NOT the NAS.
#   - Durability comes later from a restic backup of HERMES_HOME -> NAS
#     (mealie pattern), NOT from putting the live state on NFS. TODO: add
#     hermes_backup.nix once there's memory worth keeping.
#
# Dashboard access: unlike every other service here (which bind 0.0.0.0 with
# optional auth), Hermes HARD-REFUSES any non-loopback bind without a real
# auth provider. To get browser access at <vm-ai>:9119 like everything else,
# we bind the LAN IP and use basic_auth, configured entirely declaratively:
# the whole `settings` attrset renders 1:1 to config.yaml, and managed mode
# deliberately blocks `hermes config set` -- so config MUST come from here.
#
# The password_hash below is Hermes's own scrypt hash of a strong (20-char,
# ~119-bit) RANDOM password. The docs warn against putting *API keys* in
# `settings` (the store is world-readable), but a one-way scrypt hash of a
# high-entropy password is not brute-forceable in practice, so it's safe to
# commit -- exactly like an /etc/shadow line. The plaintext is stored in the
# repo's password manager / sops-outside-nix, NOT here.
#
# To change the password: regenerate the hash with Hermes's hash_password and
# replace the string below, then `pushbuild vm-ai`:
#   env=$(grep -oE "/nix/store/[a-z0-9]+-hermes-agent-env" \
#     "$(nix eval --raw .#nixosConfigurations.vm-ai.config.services.hermes-agent.package)/bin/hermes" | head -1)
#   "$env/bin/python3" -c \
#     "from plugins.dashboard_auth.basic import hash_password; print(hash_password('NEWPASS'))"

let
  llama = config.custom.world.services."llama-swap";
  hermesSvc = config.custom.world.services.hermes;
  # Hermes runs on the same VM as llama-swap, so reach it over loopback.
  endpoint = "http://127.0.0.1:${toString llama.port}/v1";
in
{
  imports = [
    # Upstream NixOS module -> provides services.hermes-agent.
    inputs.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;

    # Put the `hermes` CLI on the system PATH and export HERMES_HOME
    # system-wide, so an interactive SSH session on the VM shares state with
    # the gateway service (needed for first-run `hermes setup` / `hermes
    # model`, and day-to-day `hermes` CLI use).
    addToSystemPackages = true;

    # Define llama-swap as a named self-hosted provider. The KEY detail is
    # `transport = "openai_chat"` -> Hermes talks to /v1/chat/completions
    # (what llama.cpp implements). The built-in `openai-api` provider instead
    # uses the OpenAI *Responses* API (/v1/responses), which llama.cpp does
    # NOT support -> every request hangs ~2min then 502s. `custom` ignored our
    # base_url and routed to OpenRouter. A user-defined `providers:` entry is
    # the documented, unambiguous path for a self-hosted OpenAI-compatible box.
    # key_env names an env var holding the (dummy) key; see `environment`.
    settings.providers.llamaswap = {
      name = "llama-swap";
      base_url = endpoint;
      transport = "openai_chat";
      key_env = "OPENAI_API_KEY";
    };

    # Point Hermes at that provider + the dedicated 64k-context llama-swap
    # model (Hermes REJECTS any model with a context window < 64k at startup,
    # so the snappy 8k "qwen2.5-7b" chat model can't be used here).
    # context_length is declared to match --ctx-size 65536 -- Hermes's
    # highest-priority override, so it won't mis-probe the window.
    #
    # Managed mode blocks switching this in the UI, so it's declared here;
    # change model/endpoint -> edit + `pushbuild vm-ai`.
    settings.model = {
      default = "qwen2.5-7b-agent";
      provider = "llamaswap";
      base_url = endpoint;
      context_length = 65536;
    };

    # The openai-api provider reads its endpoint + key from these env vars
    # (written to HERMES_HOME/.env). llama-swap ignores auth, but a non-empty
    # key is required or the client sends no Authorization header. Not a real
    # secret, so inlining the dummy key is fine.
    environment = {
      OPENAI_BASE_URL = endpoint;
      OPENAI_API_KEY = "sk-noauth";
    };

    # Dashboard auth, fully declarative (rendered 1:1 into config.yaml). The
    # username is plain; password_hash is Hermes's scrypt hash of a strong
    # random password (safe to commit -- see header). This is what satisfies
    # the LAN auth gate so the dashboard serves on the VM IP.
    settings.dashboard.basic_auth = {
      username = "gideon";
      password_hash = "scrypt$16384$8$1$n+f04MsvfVh0dUEFdmtmPA==$ksicTZEiQKkiXK2bpjq4WA1WT+d/JdG3Kzktxc1g3r8=";
    };

    # Dashboard mode, bound to the VM's LAN IP so it's reachable from any
    # browser on the LAN/VPN -- same ip:port UX as every other service.
    # `waitFor = "hostname"` polls until the IP is bound before the backend
    # starts, so the unit doesn't lose the boot race against networking
    # bringing up the static address.
    backend = {
      mode = "dashboard";
      host = hermesSvc.ip;
      port = hermesSvc.port;
      waitFor = "hostname";
    };
  };

  networking.firewall.allowedTCPPorts = [ hermesSvc.port ];
}
