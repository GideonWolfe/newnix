{ config, lib, ... }:

let
  nzbgetConfigDir = "/data/nzbget/config";
  downloadsDir = config.custom.world.hosts.media.downloadsDir;
in
{

  ###########
  # Secrets #
  ###########
  # Define a secret for the NZBGet environment file
  # This contains Username/Password for the web UI
  sops.secrets."nzbget/env" = { 
    owner = "gideon";
    sopsFile = ../../secrets/secrets_media.yaml;
  };

  # Define a SOPS template for the NZBGet config
  # This gets appended to the "main" .conf file in this directory, which contains all the non-secret config options
  sops.templates."nzbget-config.conf".content = ''
    Server1.Name=NewsHosting
    Server1.Level=0
    Server1.Optional=no
    Server1.Group=0
    Server1.Host=news.newshosting.com
    Server1.Encryption=yes
    Server1.Port=563
    Server1.Username=${config.sops.placeholder."newshosting/username"}
    Server1.Password=${config.sops.placeholder."newshosting/password"}
    Server1.JoinGroup=no
    Server1.Cipher=
    Server1.Connections=60
    Server1.Retention=0
    Server1.CertVerification=Strict
    Server1.IpVersion=auto
    Server2.Active=yes
    Server2.Name=Eweka
    Server2.Level=0
    Server2.Optional=no
    Server2.Group=0
    Server2.Host=news.eweka.nl
    Server2.Encryption=yes
    Server2.Port=563
    Server2.Username=${config.sops.placeholder."eweka/username"}
    Server2.Password=${config.sops.placeholder."eweka/password"}
    Server2.JoinGroup=no
    Server2.Cipher=
    Server2.Connections=50
    Server2.Retention=0
    Server2.CertVerification=Strict
    Server2.IpVersion=auto
    Server2.Notes=
  '';

  ##############################################
  # Seed NZBGet config into the bound config dir
  ##############################################
  systemd.services.nzbget-seed-config = {
    description = "Seed NZBGet config";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-nzbget.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      set -e
      mkdir -p ${nzbgetConfigDir}
      mkdir -p ${downloadsDir}
      chown -R 1000:100 ${downloadsDir}
      if [ ! -f ${nzbgetConfigDir}/nzbget.conf ]; then
        # Append the secret-backed server block to the working base config
        cat ${./nzbget.conf} ${config.sops.templates."nzbget-config.conf".path} > ${nzbgetConfigDir}/nzbget.conf
        chmod 600 ${nzbgetConfigDir}/nzbget.conf
      fi
    '';
  };

  # Ensure the container waits for the seeded config
  systemd.services.docker-nzbget = {
    requires = [ "nzbget-seed-config.service" ];
    after = [ "nzbget-seed-config.service" ];
  };
}