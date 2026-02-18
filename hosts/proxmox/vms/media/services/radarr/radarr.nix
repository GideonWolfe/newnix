{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.radarr = {
    # https://hub.docker.com/r/linuxserver/radarr/tags
    image = "linuxserver/radarr:6.0.4";
    ports = [ "${builtins.toString config.custom.world.services.radarr.port}:7878" ];
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    volumes = [
      "/data/radarr/config/:/config/"
      "/nas/tank/media/movies/:/movies/"
      # Downloads can live on the local data disk before being copied ot the NAS
      "${config.custom.world.hosts.media.downloadsDir}:/downloads"

    ];
  };
}
