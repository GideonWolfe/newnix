{ config, lib, pkgs, ... }:
let
  dataDir = "/data/tududi";
  dumpDir = "${dataDir}/backups/db";
  backupRepo = "/nas/tank/infra/services/tududi/restic_backup";
  dockerBin = "${pkgs.docker}/bin/docker";
in
{
  services.restic.backups.tududi = {
    # Use pg_dump rather than copying PostgreSQL's live data directory.
    paths = [
      "${dataDir}/uploads"
      "${dataDir}/backups"
    ];
    repository = backupRepo;
    initialize = true;
    user = "gideon";
    passwordFile = config.sops.secrets."tududi/restic_password".path;

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
      ${pkgs.coreutils}/bin/mkdir -p ${dumpDir}
      trap '${pkgs.coreutils}/bin/rm -f ${dumpDir}/tududi.sql.tmp ${dumpDir}/tududi.sql.gz.tmp' EXIT

      # Run the matching pg_dump version inside PostgreSQL's container.
      ${dockerBin} exec tududi-db \
        pg_dump --no-owner --no-acl --username=tududi --dbname=tududi \
        > ${dumpDir}/tududi.sql.tmp
      ${pkgs.gzip}/bin/gzip -c ${dumpDir}/tududi.sql.tmp > ${dumpDir}/tududi.sql.gz.tmp
      ${pkgs.coreutils}/bin/mv -f ${dumpDir}/tududi.sql.gz.tmp ${dumpDir}/tududi.sql.gz
      ${pkgs.coreutils}/bin/rm -f ${dumpDir}/tududi.sql.tmp
    '';
  };

  systemd.services.restic-backups-tududi = {
    after = [ "docker-tududi-db-ready.service" ];
    requires = [ "docker-tududi-db-ready.service" ];
    unitConfig.RequiresMountsFor = [ dataDir backupRepo ];
    serviceConfig.UMask = "0077";
  };
}
