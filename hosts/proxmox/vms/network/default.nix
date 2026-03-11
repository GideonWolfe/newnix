{
    imports = [
        # Monitor the local network
        ./services/mikrotik-prometheus-exporter/mikrotik-prometheus-exporter.nix
    ];

    # Unique hostname for this MV
    networking.hostName = "network";
    
    # Assign an IP ourselves
    # TODO change to VM NIC name
    networking.interfaces.enp1s0.ipv4.addresses = [
        {
            address = "${config.custom.world.hosts.proxmox.vms.network.ip}";
            prefixLength = 24;
        }
    ];
}