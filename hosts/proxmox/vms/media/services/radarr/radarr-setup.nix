{ pkgs, lib, config, ... }:

let
  # Host-side path that is bind-mounted into the container as /config
  radarrConfigDir = "/data/radarr/config";
in
{

  ###########
  # Secrets #
  ###########
  # Define a secret for the Radarr API key
  sops.secrets."radarr/apikey" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };

  # Define a SOPS template for the Sonarr config.xml
  sops.templates."radarr-config.xml".content = ''
    <Config>
        <BindAddress>*</BindAddress>
        <Port>${builtins.toString config.custom.world.services.radarr.port}</Port>
        <SslPort>9898</SslPort>
        <LaunchBrowser>True</LaunchBrowser>
        <ApiKey>${config.sops.placeholder."radarr/apikey"}</ApiKey>
        <AuthenticationMethod>Basic</AuthenticationMethod>
        <AuthenticationRequired>Enabled</AuthenticationRequired>
        <Branch>main</Branch>
        <LogLevel>info</LogLevel>
        <SslCertPath></SslCertPath>
        <UrlBase></UrlBase>
        <InstanceName>Radarr</InstanceName>
        <UpdateMechanism>Docker</UpdateMechanism>
    </Config>
  '';

  ##########
  # Config #
  ##########
  # Seed config.xml on the host before the container starts
  systemd.services.radarr-seed-config = {
    description = "Seed Radarr config.xml";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-radarr.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      mkdir -p ${radarrConfigDir}
      if [ ! -f ${radarrConfigDir}/config.xml ]; then
        install -m 600 ${config.sops.templates."radarr-config.xml".path} ${radarrConfigDir}/config.xml
      fi
    '';
  };

  # Ensure the container waits for its config
  systemd.services.docker-radarr = {
    requires = [ "radarr-seed-config.service" ];
    after = [ "radarr-seed-config.service" ];
  };
}
