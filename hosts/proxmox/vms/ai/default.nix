{ config, ... }:
{
    # AI/compute VM on the pvetower node (Ryzen 9 7900X, 61 GiB). CPU-only
    # llama.cpp inference behind llama-swap. Content (models, config, prompts,
    # agents) lives on the NAS; this VM is disposable compute.
    imports = [
        ../../../../system/modules/server/ai
    ];

    # Unique hostname for this VM
    networking.hostName = "vm-ai";

    # Assign an IP ourselves (matches the Terranix-side vmid/IP convention:
    # vmid 106 <-> 192.168.88.106, declared in lib/world/hosts.nix).
    networking.interfaces.ens18.ipv4.addresses = [
        {
            address = "${config.custom.world.hosts.proxmox.vms.vm_ai.ip}";
            prefixLength = 24;
        }
    ];

    # Mount the data disk attached by Terranix (serial=data, virtio1). Same
    # pattern as vm-test/vm-app1: stable by-id path, autoFormat for fresh
    # clones, deferred mount via systemd automount so a missing disk doesn't
    # block boot. Holds the local GGUF cache under /data/ai/models.
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
    # autoFormat has a root:root root inode). Non-recursive -- only the
    # mountpoint itself is touched, contents keep their ownership.
    systemd.tmpfiles.rules = [
        "d /data 0755 1000 100 -"
    ];
}