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
    autoStart = true;
    #user= "1000:100";
    # https://github.com/Nezreka/SoulSync?tab=readme-ov-file#step-4-docker-path-mapping
    volumes = [
      "/data/soulsync/config/:/app/config"
      "/data/soulsync/data/:/app/data" # database lives here
      "/data/soulsync/staging/:/app/Staging"
      "${config.custom.world.hosts.media.downloadsDir}:/app/downloads"
      #TODO: is this mount needed?
      "/nas/tank/media/music/:/app/Transfer" #put music library in read only mode for now
    ];
  };
}
