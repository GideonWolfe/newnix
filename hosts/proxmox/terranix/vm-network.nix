{
  resource.proxmox_vm_qemu.vm_network = {
    name = "vm-network";
    target_node = "pve2";
    vmid = 1001;
    clone = "nixos-base";
    full_clone = true;

    # Auto-start on host boot so the VM recovers after a host reboot or an
    # OOM-kill of the kvm process.
    start_at_node_boot = true;

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    memory = 4096;
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
            size = "30G";
            storage = "datapool";
            format = "raw";
            replicate = true;
            serial = "rootdisk";
          };
        };
        virtio1 = {
          disk = {
            size = "5G";
            storage = "datapool";
            format = "raw";
            replicate = true;
            serial = "data";
          };
        };
      };
    };
  };
}
