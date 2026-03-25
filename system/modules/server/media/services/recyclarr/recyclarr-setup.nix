{
  pkgs,
  config,
  ...
}:

let
  recyclarrConfigDir = "/data/recyclarr2/config";
  #   recyclarrConfigFile = pkgs.writeText "recyclarr.yml" ''
  #   sonarr:
  #     tv:
  #       base_url: !secret sonarr_url
  #       api_key: !secret sonarr_apikey
  # '';
  recyclarrConfigFile = builtins.readFile ./recyclarr.yml;
in
{

  # Define a SOPS template for the Recyclarr secrets.yml
  # Uses the Sonarr API key SOPS secret
  sops.templates."recyclarr-secrets.yml".content = ''
    sonarr_url: ${config.custom.world.services.sonarr.protocol}://sonarr:${builtins.toString config.custom.world.services.sonarr.port}
    sonarr_apikey: ${config.sops.placeholder."sonarr/apikey"}
  '';

  # Seed secrets.yml and recyclarr.yml
  # Chown necessary because recyclarr wants to create files as root
  systemd.services.recyclarr-seed-secrets = {
    description = "Seed recyclarr secrets.yml";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-recyclarr.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      mkdir -p ${recyclarrConfigDir}
      if [ ! -f ${recyclarrConfigDir}/secrets.yml ]; then
        install -m 600 ${
          config.sops.templates."recyclarr-secrets.yml".path
        } ${recyclarrConfigDir}/secrets.yml
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
}
