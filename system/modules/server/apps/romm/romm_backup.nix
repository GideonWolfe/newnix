# Restic backup of Mealie's data directory to the NAS.
# Runs on the VM hosting Mealie (app1) and writes to an NFS-mounted folder on mnemosyne.
{ config, lib, ... }:
let
  # RomM's bind-mounted data on the host (see romm.nix: /data/romm/data:/app/data)
  rommDataDir = "/data/romm";
  # Pre-created folder on the NAS for application-level restic repos
  backupRepo = "/nas/tank/services/romm/restic_backup";
in
{
  services.restic.backups."romm" = {
    # What to back up
    paths = [ rommDataDir ];

    # Restic repository on the NAS (NFS-mounted via mnemosyne-nfs.nix)
    repository = backupRepo;

    # Initialize the repo on first run if it doesn't already exist
    initialize = true;

    # Repo encryption password (managed by sops)
    passwordFile = config.sops.secrets."romm/restic_password".path;
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
