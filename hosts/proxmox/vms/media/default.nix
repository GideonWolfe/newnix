{ config, ... }:
{
    imports = [
        # Get our secret definitions
        ../../../../system/modules/server/media/secrets/secrets_media.nix
        # TV Database
        ../../../../system/modules/server/media/services/sonarr/sonarr.nix
        ../../../../system/modules/server/media/services/sonarr/sonarr-setup.nix
        #../../../../system/modules/server/media/services/sonarr/sonarr-monitoring.nix

        # Movie Database
        ../../../../system/modules/server/media/services/radarr/radarr.nix
        ../../../../system/modules/server/media/services/radarr/radarr-setup.nix
        #../../../../system/modules/server/media/services/radarr/radarr-monitoring.nix

        # Push optimized settings to them
        ../../../../system/modules/server/media/services/recyclarr/recyclarr.nix
        ../../../../system/modules/server/media/services/recyclarr/recyclarr-setup.nix

        # Centralized indexer manager
        ../../../../system/modules/server/media/services/prowlarr/prowlarr.nix

        # Subtitles
        ../../../../system/modules/server/media/services/bazarr/bazarr.nix

        # Download client
        ../../../../system/modules/server/media/services/nzbget/nzbget.nix
        ../../../../system/modules/server/media/services/nzbget/nzbget-setup.nix

        # SoulSeek
        ../../../../system/modules/server/media/services/slskd/slskd.nix
        ../../../../system/modules/server/media/services/slskd/slskd-setup.nix
        # SoulSync
        ../../../../system/modules/server/media/services/soulsync/soulsync.nix
        # eh don't even bother, it ignored my JSON anyways and is being updated too fast
        #../../../../system/modules/server/media/services/soulsync/soulsync-setup.nix

        # Frontends
        ../../../../system/modules/server/media/services/jellyfin/jellyfin.nix
        ../../../../system/modules/server/media/services/seerr/seerr.nix
        ../../../../system/modules/server/media/services/seerr/seerr-setup.nix
        ../../../../system/modules/server/media/services/navidrome/navidrome.nix
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

    # Reclaim docker disk weekly: prune dangling images, stopped containers,
    # unused networks and build cache. Keeps /var/lib/docker from creeping up
    # as :latest tags pull new image layers.
    systemd.services.docker-prune = {
        description = "Prune unused docker objects";
        after = [ "docker.service" ];
        requires = [ "docker.service" ];
        serviceConfig.Type = "oneshot";
        script = ''
            /run/current-system/sw/bin/docker system prune -af --filter "until=168h"
        '';
    };
    systemd.timers.docker-prune = {
        description = "Weekly docker prune";
        wantedBy = [ "timers.target" ];
        timerConfig = {
            OnCalendar = "weekly";
            Persistent = true;
            RandomizedDelaySec = "1h";
        };
    };

    # Unique hostname for this MV
    networking.hostName = "media-vm";
    
    # Assign an IP ourselves
    # TODO change to VM NIC name
    networking.interfaces.ens18.useDHCP = false;
    networking.interfaces.ens18.ipv4.addresses = [
        {
            #address = "${config.custom.world.hosts.proxmox.vms.media_vm.ip}";
            address = "${config.custom.world.hosts.proxmox.vms.media_vm.ip}";
            prefixLength = 24;
        }
    ];


    # Now that we've spun up a VM using terraform,
    # We can guarantee that the data disk will be there
    # Uses the stable serial-based path set in Terranix (serial = "data")
    fileSystems."/data" = {
        device = "/dev/disk/by-id/virtio-data";
        fsType = "ext4";
        autoFormat = true; # avoid mkfs on existing disks during switch
        autoResize = true; # Automatically grow the FS if we changed the disk size in proxmox
        options = [
            "defaults"
            "nofail"                  # do not fail boot if disk absent
            "x-systemd.device-timeout=1s"
        ];
        neededForBoot = false;
    };

    # Non-replicated scratch volume mounted *inside* /data so that paths
    # like /data/downloads/nzbget/completed/... keep working unchanged.
    # Anything written here is considered disposable; it is excluded from
    # zfs replication on the Proxmox side (see terranix vm-media.nix).
    fileSystems."/data/downloads" = {
        device = "/dev/disk/by-id/virtio-scratch";
        fsType = "ext4";
        autoFormat = true;
        autoResize = true;
        # Ensure /data is mounted first so this lands on the correct mountpoint
        depends = [ "/data" ];
        options = [
            "defaults"
            "nofail"
            "x-systemd.device-timeout=1s"
        ];
        neededForBoot = false;
    };

    # Make the data disk owned by the media user so containers
    # (and their PUID/PGID init scripts) can create subdirectories freely.
    systemd.tmpfiles.rules = [
        "d /data                              0755 1000 100 -"
        "d /data/downloads                    0775 1000 100 -"
        "d /data/downloads/nzbget             0775 1000 100 -"
        "d /data/downloads/nzbget/completed   0775 1000 100 -"
        "d /data/downloads/nzbget/completed/tv     0775 1000 100 -"
        "d /data/downloads/nzbget/completed/movies 0775 1000 100 -"
        "d /data/downloads/soulseek           0775 1000 100 -"
        # Self-heal ownership if anything drifts (optional)
        "Z /data/downloads                    - 1000 100 -"
    ];


}