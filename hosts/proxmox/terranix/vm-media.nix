{
  resource.proxmox_vm_qemu.media_vm = {
    name = "media-vm";
    target_node = "pve1";
    vmid = 102;
    clone = "proxmox-base";
    full_clone = true;
    tags = "prod,app";

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    memory = 8192;
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
            serial = "rootdisk";
          };
        };
        virtio1 = {
          disk = {
            size = "200G";
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
