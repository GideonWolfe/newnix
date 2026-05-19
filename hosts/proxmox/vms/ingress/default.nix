{
    imports = [
        ./services/traefik/traefik.nix
        ./services/crowdsec/crowdsec.nix
    ];

    # Unique hostname for this MV
    networking.hostName = "ingress-vm";
    
    # Assign an IP ourselves
    networking.interfaces.ens18.ipv4.addresses = [
        {
            address = "${config.custom.world.proxmox.vms.ingress_vm.ip}";
            prefixLength = 24;
        }
    ];
}