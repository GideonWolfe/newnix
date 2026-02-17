{ pkgs, lib, config, ... }:

{
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
      "/data/sonarr/config/:/config/"
      "/nas/tank/media/tv/:/tv/"
      # Downloads can live on the local data disk before being copied ot the NAS
      "${config.custom.world.hosts.media.downloadsDir}:/downloads"
    ];
  };
}
