{ pkgs, lib, config, ... }:

# Mirrors the canonical GGUF library on the NAS down to the VM's local NVMe
# cache. The NAS stays the single source of truth; this just keeps a fast copy
# next to the CPU so llama-swap's model switches are seconds, not minutes.
#
# `--delete` enforces the NAS as authoritative: a model dropped from the NAS
# library is removed from the local cache too. rsync only transfers diffs, so
# the periodic run is cheap once things are in sync.

let
  cfg = config.custom.services.llama;
in
{
  systemd.services.llama-model-sync = {
    description = "Sync GGUF model library from the NAS to the local cache";

    # Needs the NFS automount live before it can read the source library.
    after = [ "network-online.target" "nas-tank.automount" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "gideon";
      Group = "users";

      # Touch the source to trigger the automount, then mirror. Trailing
      # slashes: copy the *contents* of models/ into the cache. Best-effort --
      # a NAS blip shouldn't fail the boot transaction or block llama-swap.
      #
      # rsync flags:
      #   -a            archive; the default quick-check skips any file whose
      #                 size + mtime already match, so already-synced GGUFs are
      #                 never re-transferred (no duplication, cheap steady state).
      #   --delete      mirror: drop local files no longer on the NAS, keeping
      #                 the NAS authoritative.
      #   --partial     resume an interrupted multi-GB transfer instead of
      #                 restarting from zero.
      #   --inplace     write straight to the final file (safe: GGUFs are
      #                 write-once, new model = new filename) so we don't need
      #                 ~2x the file's size free for rsync's temp copy.
      ExecStart = pkgs.writeShellScript "llama-model-sync" ''
        set -u
        src="${cfg.contentDir}/models/"
        dst="${cfg.modelCacheDir}/"
        ls "$src" >/dev/null 2>&1 || {
          echo "NAS model library not reachable at $src; skipping sync"
          exit 0
        }
        ${lib.getExe pkgs.rsync} -a --delete --partial --inplace --info=stats1 "$src" "$dst"
      '';
    };
  };

  # Periodically re-sync so new models added on the NAS show up locally without
  # a manual `systemctl start llama-model-sync`.
  systemd.timers.llama-model-sync = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };
}
