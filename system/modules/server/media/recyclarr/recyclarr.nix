{ pkgs, lib, config, ... }:

let
  recyclarrConfigDir = "/data/recyclarr2/config";
  recyclarrConfigFile = pkgs.writeText "recyclarr.yml" ''
sonarr:
  tv:
    base_url: !secret sonarr_url
    api_key: !secret sonarr_apikey
'';
in
{
  # Seed secrets.yml from the SOPS template if missing
  systemd.services.recyclarr-seed-secrets = {
    description = "Seed recyclarr secrets.yml";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-recyclarr.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      mkdir -p ${recyclarrConfigDir}
      if [ ! -f ${recyclarrConfigDir}/secrets.yml ]; then
        install -m 600 ${config.sops.templates."recyclarr-secrets.yml".path} ${recyclarrConfigDir}/secrets.yml
      fi
      if [ ! -f ${recyclarrConfigDir}/recyclarr.yml ]; then
        install -m 600 ${recyclarrConfigFile} ${recyclarrConfigDir}/recyclarr.yml
      fi
      chown -R 1000:100 ${recyclarrConfigDir}
      chmod 755 ${recyclarrConfigDir}
    '';
  };

  # Ensure the container waits for its secrets
  systemd.services.docker-recyclarr = {
    requires = [ "recyclarr-seed-secrets.service" ];
    after = [ "recyclarr-seed-secrets.service" ];
  };

  virtualisation.oci-containers.containers.recyclarr = {
    # https://hub.docker.com/r/recyclarr/recyclarr/tags
    image = "recyclarr/recyclarr:7.5.2";
    autoStart = true;
    extraOptions = [ "--network=media" ];
    user= "1000:100";
    volumes = [
      "${recyclarrConfigDir}:/config/"
    ];
  };
}
