# Restic backup of /data/karakeep (sqlite DB + uploaded assets + meili
# index) to the NAS. Runs on the VM hosting Karakeep (vm-test) and writes
# to an NFS-mounted folder on mnemosyne.
#
# Restore (on the karakeep host, as root):
#
#   systemctl start nas-tank.automount
#   restic-karakeep snapshots
#   systemctl stop docker-karakeep-{web,chrome,meili}
#   restic-karakeep restore latest --target /
#   systemctl start docker-karakeep-{meili,chrome,web}
#
# Notes:
#   - This is a HOT backup. Karakeep uses sqlite with WAL; live snapshots
#     are generally safe, but for guaranteed consistency stop the web
#     container before running an out-of-schedule restic backup.
#   - Meilisearch state IS included (regenerable from sqlite, but avoids a
#     minutes-long re-index after a restore).
{ pkgs, config, lib, ... }:
let
  karakeepDataDir = "/data/karakeep";
  backupRepo      = "/nas/tank/services/karakeep/restic_backup";
in
{
  services.restic.backups."karakeep" = {
    paths        = [ karakeepDataDir ];
    repository   = backupRepo;
    initialize   = true;
    passwordFile = config.sops.secrets."karakeep/restic_password".path;

    # Daily backup, catch up if the machine was off.
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };

    # Same retention window as the other app backups (mealie/dawarich).
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];

    # Make sure the NFS automount is up before restic runs.
    backupPrepareCommand = ''
      ${lib.getExe' config.systemd.package "systemctl"} start nas-tank.automount || true
      ls ${backupRepo} > /dev/null 2>&1 || true
    '';
  };
}
