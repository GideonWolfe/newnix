{ pkgs, lib, config, ... }:

let
  # Host-side path that is bind-mounted into the container as /config
  sonarrConfigDir = "/data/sonarr/config";
in
{
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

  virtualisation.oci-containers.containers.sonarr = {
    # https://hub.docker.com/r/linuxserver/sonarr/tags
    image = "linuxserver/sonarr:4.0.16";
    ports = [ "${builtins.toString config.custom.world.services.sonarr.port}:8989" ];
    autoStart = true;
    extraOptions = [ "--network=media" ];
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    volumes = [
      "${sonarrConfigDir}:/config/"
      "/nas/tank/media/tv/:/tv/"
      # Downloads can live on the local data disk before being copied ot the NAS
      "${config.custom.world.hosts.media.downloadsDir}:/downloads"
    ];
  };
}
