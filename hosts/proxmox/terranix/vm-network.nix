{
  resource.proxmox_vm_qemu.network_vm = {
    name = "network-vm";
    target_node = "pve2";
    vmid = 1001;
    clone = "proxmox-base";
    full_clone = true;

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
      scsi = {
        scsi0 = {
          disk = {
            size = "5G";
            storage = "datapool";
            format = "raw";
            replicate = true;
          };
        };
      };
      virtio = {
        virtio0 = {
          disk = {
            size = "30G";
            storage = "datapool";
            format = "raw";
            replicate = true;
          };
        };
      };
    };
  };
}
