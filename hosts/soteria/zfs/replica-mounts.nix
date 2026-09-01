{ pkgs, ... }:
# Declaratively guarantee that replicated leaf datasets under tank/backups are
# both MOUNTED (browsable) and read-only (protected).
#
# Why this is needed: syncoid receives replica datasets under tank/backups. If a
# *container* (a dataset with children) is readonly=on, ZFS cannot create the
# mountpoint directory for a newly received child ("failed to create mountpoint:
# Read-only file system"), so the leaf stays unmounted and unbrowsable.
#
# Policy enforced here:
#   - tank/backups (base container) -> readonly=off ALWAYS (holds no files, just
#     child datasets). Keeping it permanently writable means a new receive can
#     always create its mountpoint, eliminating the race entirely.
#   - any other container (has children) -> readonly=off
#   - leaf datasets (no children)         -> readonly=on (data protected)
# then mount everything.
#
# This runs both at boot AND on a short timer, so datasets syncoid adds later
# are protected and mounted promptly -- no boot-only gap. The base container
# staying permanently writable already prevents the mount *error*; the timer
# just re-applies readonly=on to any freshly received leaf.
let
  enforceScript = pkgs.writeShellApplication {
    name = "zfs-backups-enforce";
    runtimeInputs = [ pkgs.zfs pkgs.gnugrep ];
    text = ''
      # All datasets in the backups subtree (skip if the tree doesn't exist yet).
      all=$(zfs list -H -o name -r tank/backups 2>/dev/null || true)
      [ -n "$all" ] || exit 0

      for ds in $all; do
          if [ "$ds" = "tank/backups" ]; then
              # Base container: never holds files, keep permanently writable.
              zfs set readonly=off "$ds"
          elif printf '%s\n' "$all" | grep -q "^$ds/"; then
              # Has children -> container: keep writable for child mountpoints.
              zfs set readonly=off "$ds"
          else
              # No children -> leaf replica: protect it read-only.
              zfs set readonly=on "$ds"
          fi
      done

      # Containers are writable now, so mount anything not yet mounted.
      zfs mount -a
    '';
  };
in
{
    systemd.services.zfs-backups-mounts = {
        description = "Enforce mount + readonly policy on tank/backups replicas";
        after = [ "zfs-import.target" "zfs-mount.service" ];
        wants = [ "zfs-mount.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "oneshot";
            ExecStart = "${enforceScript}/bin/zfs-backups-enforce";
        };
    };

    # Re-apply the policy periodically so a newly received leaf doesn't sit
    # writable (or unmounted) until the next reboot.
    systemd.timers.zfs-backups-mounts = {
        description = "Periodically enforce tank/backups mount + readonly policy";
        wantedBy = [ "timers.target" ];
        timerConfig = {
            OnBootSec = "5min";
            OnUnitActiveSec = "15min";
        };
    };
}
