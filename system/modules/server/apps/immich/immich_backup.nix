# Restic backup of Immich's local data directory to the NAS.
# Runs on the VM hosting Immich (app1) and writes to an NFS-mounted folder on mnemosyne.
#
# What we back up:
#   * /data/immich           - postgres data dir + model cache (local SSD)
#
# What we DON'T back up here:
#   * /nas/tank/media/photos - the upload library already lives on the NAS,
#     which has its own snapshot/replication story (ZFS). Backing it up via
#     restic from this VM would just shuffle bytes around the same pool.
{ config, lib, ... }:
let
  # Immich's bind-mounted local data on the host (see immich.nix: ${dataDir}).
  immichDataDir = "/data/immich";

  # Pre-created folder on the NAS for application-level restic repos.
  backupRepo = "/nas/tank/services/immich/restic_backup";
in
{
  services.restic.backups."immich" = {
    # What to back up
    paths = [ immichDataDir ];

    # Restic repository on the NAS (NFS-mounted via mnemosyne-nfs.nix)
    repository = backupRepo;

    # Initialize the repo on first run if it doesn't already exist
    initialize = true;

    # Repo encryption password (managed by sops)
    passwordFile = config.sops.secrets."immich/restic_password".path;

    # Daily backup, catch up if the machine was off
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };

    # Keep a sensible retention window and prune in the same run
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];

    # Make sure the NFS automount is available before the backup runs
    backupPrepareCommand = ''
      ${lib.getExe' config.systemd.package "systemctl"} start nas-tank.automount || true
      # Touch the path to trigger the automount
      ls ${backupRepo} > /dev/null 2>&1 || true
    '';
  };
}
