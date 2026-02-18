{ config, ... }:
{
    imports = [
        # Get our secret definitions
        ./secrets/secrets_media.nix
        # TV Database
        ./services/sonarr/sonarr.nix
        ./services/sonarr/sonarr-setup.nix
        #./services/sonarr/sonarr-monitoring.nix

        # Movie Database
        #./services/radarr/radarr.nix
        #./services/radarr/radarr-monitoring.nix

        # Push optimized settings to them
        ./services/recyclarr/recyclarr.nix
        ./services/recyclarr/recyclarr-setup.nix

        # Centralized indexer manager
        #./services/prowlarr/prowlarr.nix

        # Download client
        ./services/nzbget/nzbget.nix
        ./services/nzbget/nzbget-setup.nix

        # Frontends
        #./services/jellyfin/jellyfin/jellyfin.nix
        #./services/seerr/seerr.nix
        #./services/navidrome/navidrome.nix
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


    # Now that we've spun up a VM using terraform,
    # We can guarantee that the scsi disk will be there
    fileSystems."/data" = {
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0";
        fsType = "ext4";
        autoFormat = true; # avoid mkfs on existing disks during switch
        options = [
            "defaults"
            "nofail"                  # do not fail boot if disk absent
            "noauto"                  # don't try to mount automatically on switch
            "x-systemd.automount"     # mount on first access instead
            "x-systemd.device-timeout=1s"
        ];
        neededForBoot = false;
    };

}