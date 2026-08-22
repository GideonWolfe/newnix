{ pkgs, lib, config, ... }:

# llama.cpp CPU inference, fronted by llama-swap.
#
# Design goal: keep *compute* (this VM, the binaries, the systemd unit --
# all reproducible from the flake) cleanly separated from *content* (models,
# the llama-swap config, prompts and agents -- all durable, living on the NAS).
# Nuke and rebuild this VM, move it to different hardware, and everything that
# matters survives untouched on mnemosyne.
#
# Storage split (hybrid):
#   NAS  /nas/tank/services/ai/           <- source of truth, survives rebuilds
#          models/                          canonical GGUF library
#          config/llama-swap.yaml           model definitions (edit here)
#          prompts/  agents/                your system prompts + agent library
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
# Runs as gideon:users (like copyparty/aria2) so it can read NAS content over
# NFS (uid 1000 / gid 100) without cross-user permission juggling.

let
  svc = config.custom.world.services."llama-swap";
  cfg = config.custom.services.llama;
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
      default = "/nas/tank/services/ai";
      description = ''
        Canonical, durable AI content on the NAS: the GGUF library, the
        llama-swap config, and your prompts/agents. This is what survives
        hardware and software changes to the stack.
      '';
    };

    configFile = lib.mkOption {
      type = lib.types.str;
      default = "${cfg.contentDir}/config/llama-swap.yaml";
      description = ''
        Path to the llama-swap config on the NAS. Seeded from a sane default on
        first start if absent, then owned by you -- edit it to add/tune models.
        llama-swap runs with -watch-config so edits hot-reload.
      '';
    };
  };

  config = {
    systemd.services.llama-swap = {
      description = "llama-swap (llama.cpp model-swapping proxy)";
      wantedBy = [ "multi-user.target" ];

      # Needs the NAS (config + models source) and the local cache populated
      # before it can serve anything. model-sync mirrors the library down;
      # order after it but don't hard-require it (a NAS blip shouldn't wedge
      # the whole service -- stale local models are better than none).
      after = [ "network-online.target" "nas-tank.automount" "llama-model-sync.service" ];
      wants = [ "network-online.target" "llama-model-sync.service" ];

      # llama-server is resolved by name from the config's `cmd:`, so put the
      # llama.cpp package on the unit's PATH rather than baking a store path
      # into the user-editable NAS config (which GC would eventually break).
      path = [ cfg.package ];

      serviceConfig = {
        User = "gideon";
        Group = "users";

        # Seed the NAS content skeleton (config + prompts/agents dirs) on first
        # start if it isn't there yet. Touching the paths also triggers the NFS
        # automount. Never clobbers an existing, user-edited config.
        ExecStartPre = pkgs.writeShellScript "llama-swap-seed" ''
          set -eu
          install -d -m 0755 \
            "${cfg.contentDir}" \
            "${cfg.contentDir}/config" \
            "${cfg.contentDir}/models" \
            "${cfg.contentDir}/prompts" \
            "${cfg.contentDir}/agents"
          if [ ! -f "${cfg.configFile}" ]; then
            install -m 0644 ${./config/llama-swap.yaml} "${cfg.configFile}"
            echo "seeded default llama-swap config at ${cfg.configFile}"
          fi
        '';

        ExecStart = lib.concatStringsSep " " [
          "${pkgs.llama-swap}/bin/llama-swap"
          "-config ${cfg.configFile}"
          "-listen :${toString svc.port}"
          "-watch-config"
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
