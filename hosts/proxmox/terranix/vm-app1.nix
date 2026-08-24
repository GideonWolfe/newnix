{
  resource.proxmox_vm_qemu.vm_app1 = {
    name = "vm-app1";
    target_node = "pve2";
    vmid = 101;
    clone = "nixos-base";
    full_clone = true;
    tags = "prod,app";

    # Auto-start on host boot so the VM recovers after a host reboot or after
    # the host OOM-killer reaps the kvm process (see 04:00 replication spike).
    start_at_node_boot = true;

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    # Ballooning DISABLED (balloon = 0): this VM's workload (immich + postgres
    # + other docker services) is page-cache heavy, so it needs its full 8 GiB
    # resident. With auto-ballooning on, pvestatd shrank this VM toward the old
    # 3 GiB floor during a host spike and never re-inflated it (hysteresis),
    # starving the page cache and causing immich to thrash node_modules off
    # disk (iowait pressure stall). pve2 (16 GiB, ARC capped ~1.6 GiB) can back
    # the full 8 GiB alongside ingress + home-assistant, so pin it like vm-ai.
    memory = 8192;
    balloon = 0;
    skip_ipv6 = true;

    cpu = {
      type = "host";
      sockets = 1;
      cores = 4;
    };

    network = [
      {
        model = "virtio";
        bridge = "vmbr0";
        id = 0;
      }
    ];

    disks = {
      virtio = {
        virtio0 = {
          disk = {
            size = "40G";
            storage = "datapool";
            format = "raw";
            replicate = true;
            discard = true;
            serial = "rootdisk";
          };
        };
        virtio1 = {
          disk = {
            size = "50G";
            storage = "datapool";
            format = "raw";
            replicate = true;
            discard = true;
            serial = "data";
          };
        };
      };
    };

    # See vm-ingress.nix for rationale — silences Telmate's cosmetic
    # `startup_shutdown { -1 -> null }` non-diff.
    lifecycle = {
      ignore_changes = [ "startup_shutdown" ];
    };
  };
}
