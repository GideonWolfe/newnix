{ config, ... }:
{
    imports = [
        # Monitor the local network
        ./services/mikrotik-prometheus-exporter/mikrotik-prometheus-exporter.nix
    ];

    # Unique hostname for this VM
    networking.hostName = "vm-network";
    
    # Assign an IP ourselves
    # TODO change to VM NIC name
    # TODO: add `vm_network` entry to lib/world/hosts.nix when this VM is wired up
    networking.interfaces.enp1s0.ipv4.addresses = [
        {
            address = "${config.custom.world.hosts.proxmox.vms.vm_network.ip}";
            prefixLength = 24;
        }
    ];
}