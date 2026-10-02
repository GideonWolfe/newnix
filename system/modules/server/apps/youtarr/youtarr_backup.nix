{ config, pkgs, ... }:
let
  dataDir = "/data/youtarr";
  dumpDir = "${dataDir}/backup";
  backupRepo = "/nas/tank/infra/services/youtarr/restic_backup";
in
{
  services.restic.backups.youtarr = {
    # Use a transactional SQL dump, not a copy of a running MariaDB data directory.
    # Media already lives on the NAS and is covered by its ZFS backup policy.
    paths = [
      "${dataDir}/config"
      "${dataDir}/jobs"
      "${dataDir}/images"
      dumpDir
    ];
    repository = backupRepo;
    initialize = true;
    # Match the NAS media owner, including on exports with root squashing.
    user = "gideon";
    passwordFile = config.sops.secrets."youtarr/restic_password".path;
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
      set -eu
      umask 077
      trap '${pkgs.coreutils}/bin/rm -f ${dumpDir}/youtarr.sql.tmp' EXIT
      ${pkgs.coreutils}/bin/mkdir -p ${backupRepo}
      # Root can dump routines/events too; its password stays inside the DB container.
      ${pkgs.docker}/bin/docker exec youtarr-db sh -c \
        'MYSQL_PWD="$MARIADB_ROOT_PASSWORD" exec mariadb-dump --user=root --single-transaction --quick --routines --triggers --events --databases "$MARIADB_DATABASE"' \
        > ${dumpDir}/youtarr.sql.tmp
      ${pkgs.coreutils}/bin/mv ${dumpDir}/youtarr.sql.tmp ${dumpDir}/youtarr.sql
    '';
  };

  systemd.services.restic-backups-youtarr = {
    after = [ "docker-youtarr-db.service" ];
    requires = [ "docker-youtarr-db.service" ];
    unitConfig.RequiresMountsFor = [ dataDir backupRepo ];
  };

  systemd.tmpfiles.rules = [
    "d ${dumpDir} 0700 1000 100 - -"
  ];
}