{ config, lib, pkgs, ... }:
let
  container = config.virtualisation.oci-containers.containers.forgejo;
  dataDir = "/data/forgejo";
  codeDir = "/nas/tank/personal/code";
  backupRepo = "/nas/tank/infra/services/forgejo/restic_backup";
  containerUnit = "${container.serviceName}.service";
in
{
  services.restic.backups.forgejo = {
    # Stopping the container stops web, mirrors and Git SSH before one complete snapshot.
    paths = [ dataDir "${codeDir}/repositories" "${codeDir}/lfs" ];
    exclude = [ "${dataDir}/data/log" ];
    repository = backupRepo;
    initialize = true;
    user = "gideon"; # Same 1000:100 identity as the container and squashed NAS writes.
    passwordFile = config.sops.secrets."forgejo/restic_password".path;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
    backupPrepareCommand = ''
      set -eu
      # Fail closed if Docker could not stop the container or setup is still incomplete.
      running="$(${pkgs.docker}/bin/docker ps --quiet --filter 'name=^/forgejo$')"
      test -z "$running"
      test -s ${lib.escapeShellArg "${dataDir}/data/forgejo.db"}
      ${pkgs.coreutils}/bin/printf '%s\n' ${lib.escapeShellArg container.image} \
        > ${lib.escapeShellArg "${dataDir}/container-image.txt"}
    '';
  };

  systemd.services.restic-backups-forgejo = {
    # Restart on success or failure; starting the container first cancels a running backup.
    conflicts = [ containerUnit ];
    after = [ containerUnit ];
    onSuccess = [ containerUnit ];
    onFailure = [ containerUnit ];
    unitConfig.RequiresMountsFor = [ dataDir codeDir backupRepo ];
    serviceConfig.UMask = "0077";
  };
}