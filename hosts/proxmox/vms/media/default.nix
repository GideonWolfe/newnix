{
    imports = [
        # TV Database
        #../../../system/modules/server/media/sonarr/sonarr.nix
        #../../../system/modules/server/media/sonarr/sonarr-monitoring.nix

        # Movie Database
        #../../../system/modules/server/media/radarr/radarr.nix
        #../../../system/modules/server/media/radarr/radarr-monitoring.nix

        # Push optimized settings to them
        #../../../system/modules/server/media/recyclarr/recyclarr.nix

        # Centralized indexer manager
        #../../../system/modules/server/media/prowlarr/prowlarr.nix

        # Download client
        ../../../system/modules/server/media/nzbget/nzbget.nix

        # Frontends
        #../../../system/modules/server/media/jellyfin/jellyfin.nix
        #../../../system/modules/server/media/seerr/seerr.nix
        #../../../system/modules/server/media/navidrome/navidrome.nix
    ];

    # Unique hostname for this MV
    networking.hostName = "media-vm";
    
    # Assign an IP ourselves
    # TODO change to VM NIC name
    networking.interfaces.enp1s0.ipv4.addresses = [
        {
            address = "${config.world.proxmox.vms.media_vm.ip}";
            prefixLength = 24;
        }
    ];
}