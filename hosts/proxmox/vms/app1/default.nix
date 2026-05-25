{config, ...}:
{
    imports = [
        #../../../../system/modules/server/apps/kiwix/kiwix.nix
        ../../../../system/modules/server/apps/romm/romm.nix
        ../../../../system/modules/server/apps/mealie
        ../../../../system/modules/server/apps/calibre-web-automated
        ../../../../system/modules/server/apps/pinchflat
        ../../../../system/modules/server/apps/immich
        ../../../../system/modules/server/apps/dawarich
        ../../../../system/modules/server/apps/karakeep
    ];

    # Unique hostname for this VM
    networking.hostName = "vm-app1";
    
    # Assign an IP ourselves
    networking.interfaces.ens18.ipv4.addresses = [
        {
            address = "${config.custom.world.hosts.proxmox.vms.vm_app1.ip}";
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

    # Fresh ext4 from `autoFormat = true` has a root:root root inode, which
    # means `/data` is unwritable for normal users until someone chowns it.
    # Adjust the mountpoint's ownership to `gideon:users` (UID 1000 / GID 100)
    # so `xcp` / `rsync` / `cp` from the NAS work without sudo on a fresh VM.
    #
    # `d` is non-recursive: it only touches the mountpoint directory itself,
    # NOT its contents — so anything you've already copied in keeps its
    # original ownership. (Use `Z` if you ever want recursive self-heal.)
    systemd.tmpfiles.rules = [
        "d /data 0755 1000 100 -"
    ];
}