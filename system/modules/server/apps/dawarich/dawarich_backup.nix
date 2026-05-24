# Restic backup of /data/dawarich (postgres + Active Storage + public/ +
# fresh pg_dumpall) to the NAS. Run on the app VM.
#
# Restore (on the app VM, as root - `restic-dawarich` has the repo path +
# password baked in by the NixOS restic module):
#
#   systemctl start nas-tank.automount
#   restic-dawarich snapshots
#   systemctl stop docker-dawarich-{app,sidekiq,db}
#   restic-dawarich restore latest --target /
#   nixos-rebuild switch
#   gunzip < /data/dawarich/backups/dump.sql.gz \
#     | docker exec -i dawarich-db psql --username=dawarich
#
# `--target /` is correct: snapshots store absolute paths. Don't run this
# on the NAS itself - it would splat the tree onto the NAS root.
{ pkgs, config, lib, ... }:
let
  dawarichDataDir = "/data/dawarich";
  dumpDir         = "${dawarichDataDir}/backups";
  dumpFile        = "${dumpDir}/dump.sql.gz";
  backupRepo      = "/nas/tank/services/dawarich/restic_backup";
  postgresUser    = "dawarich";
  dockerBin       = "${pkgs.docker}/bin/docker";
in
{
  services.restic.backups."dawarich" = {
    paths        = [ dawarichDataDir ];
    repository   = backupRepo;
    initialize   = true;
    passwordFile = config.sops.secrets."dawarich/restic_password".path;

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

    # Ensure the NAS is mounted, then take a fresh pg_dumpall so it travels
    # in the same snapshot. Skip the dump if the db container isn't running.
    backupPrepareCommand = ''
      set -eu

      # Make sure the NFS automount is available before the backup runs.
      ${lib.getExe' config.systemd.package "systemctl"} start nas-tank.automount || true
      ls ${backupRepo} > /dev/null 2>&1 || true

      # Take a fresh pg_dumpall (per the upstream backup guide). The container
      # must be running for this to succeed; if it's not, skip and let restic
      # ship whatever previous dump is on disk.
      mkdir -p ${dumpDir}
      if ${dockerBin} ps --format '{{.Names}}' | grep -q '^dawarich-db$'; then
        ${dockerBin} exec -t dawarich-db \
          pg_dumpall --clean --if-exists --username=${postgresUser} \
          | ${pkgs.gzip}/bin/gzip > ${dumpFile}.tmp
        mv -f ${dumpFile}.tmp ${dumpFile}
      else
        echo "dawarich-db container is not running, skipping pg_dumpall" >&2
      fi
    '';
  };
}
