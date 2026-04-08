{
  resource.proxmox_vm_qemu.ingress_vm = {
    name = "ingress-vm";
    target_node = "pve2";
    vmid = 1000;
    clone = "proxmox-base";
    full_clone = true;

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    memory = 2048;
    skip_ipv6 = true;

    cpu = {
      type = "host";
      sockets = 1;
      cores = 2;
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
          };
        };
        virtio1 = {
          disk = {
            size = "10G";
            storage = "datapool";
            format = "raw";
            replicate = true;
          };
        };
      };
    };
  };
}
