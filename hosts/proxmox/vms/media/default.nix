{
    imports = [
        ../../../system/modules/server/media/sonarr/sonarr.nix
        ../../../system/modules/server/media/sonarr/sonarr-monitoring.nix

        ../../../system/modules/server/media/jellyfin/jellyfin.nix
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