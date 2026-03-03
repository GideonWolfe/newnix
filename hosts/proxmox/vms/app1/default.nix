{
    imports = [
        ./services/mealie
        ./services/booklore
        ./services/romm
    ];

    # Unique hostname for this MV
    networking.hostName = "app1-vm";
    
    # Assign an IP ourselves
    # TODO change to VM NIC name
    networking.interfaces.enp1s0.ipv4.addresses = [
        {
            address = "${config.world.proxmox.vms.app1_vm.ip}";
            prefixLength = 24;
        }
    ];
}