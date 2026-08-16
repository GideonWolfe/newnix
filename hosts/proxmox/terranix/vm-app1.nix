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
    # `memory` is the cap; `balloon` is the floor the host can shrink us to
    # under memory pressure. Keep balloon below memory so pve2 can reclaim
    # RAM from this VM during the 04:00 replication spike instead of
    # OOM-killing the kvm process.
    memory = 8192;
    balloon = 3072;
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
