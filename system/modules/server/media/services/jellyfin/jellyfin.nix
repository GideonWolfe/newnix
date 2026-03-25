{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.jellyfin = {
    image = "linuxserver/jellyfin:latest";
    ports = [ "${config.custom.world.services.jellyfin.port}:8096" ];
    autoStart = true;
    # Ensure it runs as a regular user
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    # Important volumes
    volumes = [
      # This is virtual disk attached by proxmox
      "/data/jellyfin/config/:/config"
      # This is the LAN NAS
      "/nas/tank/media/tv/:/data/tvshows"
      "/nas/tank/media/movies/:/data/movies"
      "/nas/tank/media/music/:/data/music"
      # jellyfin.org/docs/general/administration/backup-and-restore/
      # When I trigger a backup from the Jellyfin UI, it will save to the NAS
      "/nas/tank/app-backups/jellyfin/:/config/data/backups"
    ];
  };
}
