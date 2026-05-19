{ config, ... }:
{
    imports = [
        # SOPS secret declarations for traefik/crowdsec
        ./secrets/secrets_ingress.nix

        ./services/traefik/traefik.nix
        ./services/crowdsec/crowdsec.nix
    ];

    # Unique hostname for this VM
    networking.hostName = "ingress-vm";

    # Assign an IP ourselves
    networking.interfaces.ens18.ipv4.addresses = [
        {
            address = "${config.custom.world.hosts.proxmox.vms.ingress_vm.ip}";
            prefixLength = 24;
        }
    ];

    # Mount the data disk attached by Terranix (serial=data).
    # Used for traefik state (ACME json, plugin storage) and crowdsec data.
    fileSystems."/data" = {
        device = "/dev/disk/by-id/virtio-data";
        fsType = "ext4";
        autoFormat = true;
        autoResize = true;
        options = [
            "defaults"
            "nofail"
            "x-systemd.device-timeout=1s"
        ];
        neededForBoot = false;
    };
}