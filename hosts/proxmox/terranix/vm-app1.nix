{
  resource.proxmox_vm_qemu.vm_app1 = {
    name = "vm-app1";
    target_node = "pve2";
    vmid = 101;
    clone = "nixos-base";
    full_clone = true;
    tags = "prod,app";

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    memory = 4096;
    balloon = 1536;
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
            size = "50G";
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
  };
}
