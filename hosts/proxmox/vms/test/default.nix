{ config, ... }:
{
    # Sandbox VM (lives on pve3). Modules below are the apps currently
    # being trialled here — promote to a dedicated VM once they're stable.
    imports = [
        #../../../../system/modules/server/apps/tududi
        #../../../../system/modules/server/apps/vikunja
        ../../../../system/modules/server/apps/baikal
        ../../../../system/modules/server/apps/karakeep
    ];

    # Unique hostname for this VM
    networking.hostName = "vm-test";

    # Assign an IP ourselves (matches the Terranix-side vmid/IP convention:
    # vmid 103 ↔ 192.168.88.103, declared in lib/world/hosts.nix).
    networking.interfaces.ens18.ipv4.addresses = [
        {
            address = "${config.custom.world.hosts.proxmox.vms.vm_test.ip}";
            prefixLength = 24;
        }
    ];

    # Mount the data disk attached by Terranix (serial=data, virtio1).
    # Same pattern as vm-app1: stable by-id path, autoFormat for fresh
    # clones, deferred mount via systemd automount so a missing disk
    # doesn't block boot.
    fileSystems."/data" = {
        device = "/dev/disk/by-id/virtio-data";
        fsType = "ext4";
        autoFormat = true;
        options = [
            "defaults"
            "nofail"
            "noauto"
            "x-systemd.automount"
            "x-systemd.device-timeout=1s"
        ];
        neededForBoot = false;
    };

    # Make /data writable by gideon:users on first boot (fresh ext4 from
    # autoFormat has a root:root root inode). Non-recursive — only the
    # mountpoint itself is touched, contents keep their ownership.
    systemd.tmpfiles.rules = [
        "d /data 0755 1000 100 -"
    ];
}
