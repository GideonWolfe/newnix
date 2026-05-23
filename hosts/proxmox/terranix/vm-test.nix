{
  resource.proxmox_vm_qemu.test_vm = {
    name = "test-vm";
    target_node = "pve2";
    vmid = 103;
    clone = "nixos-base";
    full_clone = true;
    tags = "test,app";

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    memory = 4096;
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
            size = "40G";
            storage = "datapool";
            format = "raw";
            replicate = true;
            serial = "rootdisk";
          };
        };
        virtio1 = {
          disk = {
            size = "30G";
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
