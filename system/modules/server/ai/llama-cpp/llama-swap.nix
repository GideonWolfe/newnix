{ pkgs, lib, config, ... }:

# llama.cpp CPU inference, fronted by llama-swap.
#
# Design goal: keep *compute + config* (this VM, the binaries, the systemd
# unit, and the llama-swap config -- all reproducible from the flake) cleanly
# separated from *content* (models and prompts/agents -- durable data that's
# either too big or too user-owned to live in the Nix store, kept on the NAS).
# Nuke and rebuild this VM, move it to different hardware, and everything that
# matters survives: the config from the repo, the models + prompts from the NAS.
#
# The llama-swap config is CODE, not content: it's a declarative service
# definition, so it's generated from the `settings` attrset below and rendered
# to a YAML file in the Nix store. The repo is the single source of truth --
# edit `settings`, rebuild, and the new config is placed on the VM and the
# service restarted automatically. No hand-editing a live file on the NAS.
#
# Storage split:
#   repo/store  llama-swap.yaml            <- generated from `settings` (code)
#   NAS  /nas/tank/infra/ai/
#          models/                           canonical GGUF library (content)
#          prompts/  agents/                 system prompts + agent library
#   Local /data/ai/models/                 <- fast NVMe cache llama-server loads
#                                             from (mirrored from the NAS by
#                                             model-sync.nix)
#
# Why the local cache? Model location only affects cold-load/swap time, not
# token throughput (once mmap'd it's all RAM). But loading a ~20 GiB GGUF over
# NFS on every llama-swap model switch is a 1-3 min stall; off local NVMe it's
# a few seconds. So the NAS holds the library, model-sync mirrors it down, and
# llama-swap loads from the local copy.
#
# Runs as gideon:users (like copyparty/aria2) so it can read the NAS-synced
# models (uid 1000 / gid 100) without cross-user permission juggling.

let
  svc = config.custom.world.services."llama-swap";
  cfg = config.custom.services.llama;

  # Render the `settings` attrset to a YAML file in the Nix store. This is the
  # file llama-swap actually reads -- the repo is the source of truth.
  yamlFormat = pkgs.formats.yaml { };
  configFile = yamlFormat.generate "llama-swap.yaml" cfg.settings;
in
{
  options.custom.services.llama = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.llama-cpp;
      description = ''
        The llama.cpp package providing `llama-server`. The stock build already
        does runtime CPU-feature dispatch (AVX2/AVX-512), so on the Zen 4 host
        it uses AVX-512 automatically. Override with a `-march=native` build if
        you want to squeeze out the last few percent (at the cost of a
        non-cacheable, host-specific rebuild).
      '';
    };

    modelCacheDir = lib.mkOption {
      type = lib.types.str;
      default = "/data/ai/models";
      description = ''
        Local NVMe cache that llama-server actually loads GGUFs from. Mirrored
        from the NAS library by model-sync.nix. Rebuildable -- safe to lose.
      '';
    };

    contentDir = lib.mkOption {
      type = lib.types.str;
      default = "/nas/tank/infra/ai";
      description = ''
        Durable AI *content* on the NAS -- reserved for artifacts that can't
        (or shouldn't) live in version control: the GGUF library (models/,
        too big for git) and, later, agent memory/state (generated at runtime,
        irreplaceable). Config AND persona prompts are versionable text, so
        they live in the repo and are rendered into the Nix store instead.
        model-sync.nix pulls `${cfg.contentDir}/models` down to modelCacheDir.
      '';
    };

    settings = lib.mkOption {
      type = yamlFormat.type;
      description = ''
        The llama-swap configuration, as a Nix attrset rendered to YAML in the
        Nix store. This is the single source of truth for which models exist
        and how they run -- edit it here and rebuild; the new config is placed
        on the VM and llama-swap restarted automatically.

        Note: `''${PORT}` in a model's `cmd` is a llama-swap placeholder (it
        injects the upstream port), so it's escaped from Nix interpolation.
      '';
      default = {
        healthCheckTimeout = 300;
        logLevel = "info";

        models = {
          # Snappy daily driver -- ~6 GB, 8-15 tok/s.
          "qwen2.5-7b" = {
            # --threads 12    pin to physical cores (SMT threads hurt throughput)
            # --ctx-size      long context grows the KV cache in RAM
            # --jinja         enables the chat template + tool/function calling
            # --cache-reuse   reuse the KV cache for an unchanged prompt PREFIX
            #                 across turns instead of re-evaluating it. Huge win
            #                 on CPU for multi-turn chat clients that resend the
            #                 full system prompt + history every request.
            cmd = ''
              llama-server
              --model ${cfg.modelCacheDir}/qwen2.5-7b-instruct-q4_k_m.gguf
              --host 127.0.0.1 --port ''${PORT}
              --ctx-size 8192
              --threads 12
              --jinja
              --cache-reuse 256
            '';
            ttl = 300;
          };
        };
      };
    };
  };

  config = {
    systemd.services.llama-swap = {
      description = "llama-swap (llama.cpp model-swapping proxy)";
      wantedBy = [ "multi-user.target" ];

      # Config is in the store; models come from the local cache. Order after
      # model-sync so the cache is populated, but don't hard-require it (a NAS
      # blip shouldn't wedge the service -- stale local models beat none).
      after = [ "network-online.target" "llama-model-sync.service" ];
      wants = [ "network-online.target" "llama-model-sync.service" ];

      # llama-swap only needs the local model cache now (config lives in the
      # store, not on the NAS). /data is an x-systemd.automount mountpoint, so
      # force systemd to trigger + wait for it before llama-server loads a
      # cached GGUF. [Unit] directive -> unitConfig (ignored in [Service]).
      unitConfig.RequiresMountsFor = [ "/data" ];

      # llama-server is resolved by name from each model's `cmd`, so put the
      # llama.cpp package on the unit's PATH.
      path = [ cfg.package ];

      serviceConfig = {
        User = "gideon";
        Group = "users";

        ExecStart = lib.concatStringsSep " " [
          "${pkgs.llama-swap}/bin/llama-swap"
          "-config ${configFile}"
          "-listen :${toString svc.port}"
        ];

        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    # LAN/VPN-only exposure of the llama-swap endpoint.
    networking.firewall.allowedTCPPorts = [ svc.port ];

    # Own the local model cache as gideon:users so model-sync (which runs as
    # gideon) and llama-server can read/write it. Non-recursive `d`.
    systemd.tmpfiles.rules = [
      "d /data/ai            0755 1000 100 - -"
      "d ${cfg.modelCacheDir} 0755 1000 100 - -"
    ];
  };
}
