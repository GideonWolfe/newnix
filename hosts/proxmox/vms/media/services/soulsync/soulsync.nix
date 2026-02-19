{ config, ... }:
{
  virtualisation.oci-containers.containers.soulsync-webui = {
    # https://hub.docker.com/r/boulderbadgedad/soulsync/tags
    image = "boulderbadgedad/soulsync:1.6";
    extraOptions = [ "--network=media" ];
    ports = [
      "${builtins.toString config.custom.world.services.soulsync-webui.port}:8008"
      "8888:8888" # Spotify OAuth Callback
    ];
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    autostart = true;
    # https://github.com/Nezreka/SoulSync?tab=readme-ov-file#step-4-docker-path-mapping
    volumes = [
      "/data/soulsync/config/:/app/config"
      "/data/soulsync/data/:/app/data" # database lives here
      "/data/soulsync/stagint/:/app/Staging"
      "${config.custom.world.hosts.media.downloadsdir}:/app/downloads" # shared dir between all apps
      #TODO: is this mount needed?
      "/nas/tank/media/music/:/app/Transfer:ro" #put music library in read only mode for now
    ];
  };
}
