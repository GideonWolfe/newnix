{ config, ... }:
{
    imports = [
        # TV Database
        ../../../../system/modules/server/media/sonarr/sonarr.nix
        #../../../../system/modules/server/media/sonarr/sonarr-monitoring.nix

        # Movie Database
        #../../../../system/modules/server/media/radarr/radarr.nix
        #../../../../system/modules/server/media/radarr/radarr-monitoring.nix

        # Push optimized settings to them
        #../../../../system/modules/server/media/recyclarr/recyclarr.nix

        # Centralized indexer manager
        #../../../../system/modules/server/media/prowlarr/prowlarr.nix

        # Download client
        ../../../../system/modules/server/media/nzbget/nzbget.nix

        # Frontends
        #../../../../system/modules/server/media/jellyfin/jellyfin.nix
        #../../../../system/modules/server/media/seerr/seerr.nix
        #../../../../system/modules/server/media/navidrome/navidrome.nix
    ];

        # Ensure media docker network exists on this host only
        systemd.services.docker-create-media-network = {
            description = "Create media docker bridge network";
            after = [ "docker.service" ];
            requires = [ "docker.service" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig.Type = "oneshot";
            script = ''
                /run/current-system/sw/bin/docker network inspect media >/dev/null 2>&1 || \
                    /run/current-system/sw/bin/docker network create media
            '';
        };

    # Unique hostname for this MV
    networking.hostName = "media-vm";
    
    # Assign an IP ourselves
    # TODO change to VM NIC name
    networking.interfaces.ens18.useDHCP = false;
    networking.interfaces.ens18.ipv4.addresses = [
        {
            address = "${config.custom.world.hosts.media.ip}";
            prefixLength = 24;
        }
    ];
}