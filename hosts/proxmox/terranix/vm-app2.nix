{
  resource.proxmox_vm_qemu.vm_app2 = {
    name = "vm-app2";
    target_node = "pve3";
    vmid = 104;
    clone = "nixos-base";
    full_clone = true;
    tags = "prod,app";

    # Auto-start on host boot so the VM recovers after a host reboot or an
    # OOM-kill of the kvm process.
    start_at_node_boot = true;

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    memory = 8192;
    balloon = 1536;
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
