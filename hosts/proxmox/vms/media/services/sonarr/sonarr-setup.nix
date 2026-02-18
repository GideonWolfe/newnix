{ pkgs, lib, config, ... }:

let
  # Host-side path that is bind-mounted into the container as /config
  sonarrConfigDir = "/data/sonarr/config";
in
{

  ###########
  # Secrets #
  ###########
  # Define a secret for the Sonarr API key
  sops.secrets."sonarr/apikey" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };

  # Define a SOPS template for the Sonarr config.xml
  sops.templates."sonarr-config.xml".content = ''
    <Config>
        <BindAddress>*</BindAddress>
        <Port>${builtins.toString config.custom.world.services.sonarr.port}</Port>
        <LaunchBrowser>True</LaunchBrowser>
        <ApiKey>${config.sops.placeholder."sonarr/apikey"}</ApiKey>
        <Branch>main</Branch>
        <LogLevel>info</LogLevel>
        <UpdateMechanism>Docker</UpdateMechanism>
    </Config>
  '';

  ##########
  # Config #
  ##########
  # Seed config.xml on the host before the container starts
  systemd.services.sonarr-seed-config = {
    description = "Seed Sonarr config.xml";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-sonarr.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      mkdir -p ${sonarrConfigDir}
      if [ ! -f ${sonarrConfigDir}/config.xml ]; then
        install -m 600 ${config.sops.templates."sonarr-config.xml".path} ${sonarrConfigDir}/config.xml
      fi
    '';
  };

  # Ensure the container waits for its config
  systemd.services.docker-sonarr = {
    requires = [ "sonarr-seed-config.service" ];
    after = [ "sonarr-seed-config.service" ];
  };
}
