{
    imports = [
        ./traefik/traefik.nix
        ./crowdsec/crowdsec.nix
    ];

    # Unique hostname for this MV
    networking.hostName = "ingress-vm";
    
    # Assign an IP ourselves
    # TODO change to VM NIC name
    networking.interfaces.enp1s0.ipv4.addresses = [
        {
            address = "${config.world.proxmox.vms.ingress_vm.ip}";
            prefixLength = 24;
        }
    ];
}