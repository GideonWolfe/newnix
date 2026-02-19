{ pkgs, lib, config, ... }:

let
  # Host-side path that is bind-mounted into the container as /app
  slskdConfigDir = "/data/slskd/app";
in
{

  ###########
  # Secrets #
  ###########
  # Define secrets for slskd
  sops.secrets."slskd/username" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };
  sops.secrets."slskd/password" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };
  sops.secrets."slskd/apikey" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };
  sops.secrets."soulseek/username" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };
  sops.secrets."soulseek/password" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };

  # Define a SOPS template for the Sonarr config.xml
  sops.templates."slskd-slskd.yml".content = ''
    shares:
      directories:
        - /music
    web:
      authentication:
        username: "${config.sops.placeholder."slskd/username"}"
        password: "${config.sops.placeholder."slskd/password"}"
        api_keys:
          my_key:
            key: "${config.sops.placeholder."slskd/apikey"}"
    directories:
      downloads: /downloads
      incomplete: /downloads
    soulseek:
      username: "${config.sops.placeholder."soulseek/username"}"
      password: "${config.sops.placeholder."soulseek/password"}"
  '';

  ##########
  # Config #
  ##########
  # Seed slskd.yml on the host before the container starts
  systemd.services.slskd-seed-config = {
    description = "Seed slskd slskd.yml";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-slskd.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      set -e
      mkdir -p ${slskdConfigDir}
      if [ ! -f ${slskdConfigDir}/slskd.yml ]; then
        install -m 600 ${config.sops.templates."slskd-slskd.yml".path} ${slskdConfigDir}/slskd.yml
      fi
      # Ensure the config remains readable by the host user and container
      chown -R 1000:100 ${slskdConfigDir}
      chmod 0640 ${slskdConfigDir}/slskd.yml
    '';
  };

  # Ensure the container waits for its config
  systemd.services.docker-slskd = {
    requires = [ "slskd-seed-config.service" ];
    after = [ "slskd-seed-config.service" ];
  };
}
