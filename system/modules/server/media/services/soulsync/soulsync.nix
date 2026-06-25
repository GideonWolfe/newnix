{ config, ... }:
{
  virtualisation.oci-containers.containers.soulsync-webui = {
    # https://hub.docker.com/r/boulderbadgedad/soulsync/tags
    image = "boulderbadgedad/soulsync:2.7.8";
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
      "${config.custom.world.hosts.proxmox.vms.vm_media.musicDownloadsDir}:/app/downloads"
      # https://github.com/Nezreka/SoulSync/blob/ec99d686cc75886e3406cf517aaf6b54ad2fcedb/docker-compose.yml#L62
      # have a custom separate downloads folder for the usenet downloader, so that it doesn't get mixed up with the main downloads folder
      # yes, according to the docs it should be at /downloads/usenet and not /app/downloads/usenet...
      "${config.custom.world.hosts.proxmox.vms.vm_media.downloadsDir}:/downloads/usenet"
      "/nas/tank/media/music/:/app/Transfer"
    ];
  };
}
