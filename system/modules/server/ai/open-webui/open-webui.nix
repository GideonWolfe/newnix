{ lib, config, ... }:

# Open WebUI -- a persistent, always-reachable web GUI on the AI VM. It talks
# to the local llama-swap OpenAI-compatible endpoint (127.0.0.1:llama-swap),
# so every model + persona llama-swap exposes shows up in the UI's model
# picker with no per-client setup.
#
# Storage note: Open WebUI's stateDir (/var/lib/open-webui) holds genuinely
# irreplaceable runtime state -- user accounts, chat history, saved prompts,
# uploaded docs. It lives on the VM's local disk (SQLite doesn't play well
# over NFS), so durability should come from a restic backup to the NAS (see
# the mealie pattern) rather than storing it on the NAS directly. TODO: add
# open-webui_backup.nix once we care about retaining chats.

let
  webui = config.custom.world.services.open-webui;
  llama = config.custom.world.services."llama-swap";
in
{
  services.open-webui = {
    enable = true;

    # Listen on all interfaces so it's reachable over the LAN/VPN, not just
    # localhost. Exposure stays LAN/VPN-only (no Traefik router, no public DNS).
    host = "0.0.0.0";
    port = webui.port;

    # Punch the UI port through the firewall (module-managed).
    openFirewall = true;

    environment = {
      # Keep upstream's telemetry opt-outs (setting `environment` replaces the
      # module default, so re-declare them here).
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";

      # We serve models via llama.cpp/llama-swap, not Ollama -- disable the
      # Ollama backend so the UI doesn't probe a nonexistent :11434.
      ENABLE_OLLAMA_API = "False";

      # Point the OpenAI backend at the local llama-swap endpoint. llama-swap
      # ignores auth, but Open WebUI still wants a non-empty key.
      OPENAI_API_BASE_URL = "http://127.0.0.1:${toString llama.port}/v1";
      OPENAI_API_KEY = "sk-noauth";

      # Single-node LAN box: don't force login for now. Flip to "True" (and
      # restart) if you want per-user accounts before exposing it more widely.
      WEBUI_AUTH = "False";
    };
  };
}
