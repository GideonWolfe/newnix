# Restic backup of /data/tubearchivist (downloaded media + cache + redis +
# ES indices) to the NAS. Runs on the VM hosting TubeArchivist (vm-app2)
# and writes to an NFS-mounted folder on mnemosyne.
#
# Restore (on the TA host, as root):
#
#   systemctl start nas-tank.automount
#   restic-tubearchivist snapshots
#   systemctl stop docker-tubearchivist docker-archivist-es docker-archivist-redis
#   restic-tubearchivist restore latest --target /
#   systemctl start docker-archivist-es docker-archivist-redis docker-tubearchivist
#
# Notes:
#   - HOT backup. Elasticsearch is mostly tolerant of file-level snapshots
#     for single-node setups, but for guaranteed consistency stop the ES
#     container before any out-of-schedule run.
#   - The ES index dir is the bulk of the data here; expect large repos.
{ pkgs, config, lib, ... }:
let
  tubearchivistDataDir = "/data/tubearchivist";
  backupRepo           = "/nas/tank/infra/services/tubearchivist/restic_backup";
in
{
  services.restic.backups."tubearchivist" = {
    paths        = [ tubearchivistDataDir ];
    repository   = backupRepo;
    initialize   = true;
    passwordFile = config.sops.secrets."tubearchivist/restic_password".path;

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];

    backupPrepareCommand = ''
      ${lib.getExe' config.systemd.package "systemctl"} start nas-tank.automount || true
      ls ${backupRepo} > /dev/null 2>&1 || true
    '';
  };
}
