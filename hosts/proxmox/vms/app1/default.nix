{config, ...}:
{
    imports = [
        ../../../../system/modules/server/apps/kiwix/kiwix.nix
        #./services/romm
    ];

    # Unique hostname for this VM
    networking.hostName = "app1-vm";
    
    # Assign an IP ourselves
    networking.interfaces.ens18.ipv4.addresses = [
        {
            address = "${config.custom.world.hosts.proxmox.vms.app1_vm.ip}";
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