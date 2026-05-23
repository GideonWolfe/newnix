{
  resource.proxmox_vm_qemu.ingress_vm = {
    name = "ingress-vm";
    target_node = "pve2";
    vmid = 100;
    clone = "nixos-base";
    full_clone = true;
    tags = "prod,network";

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    # `memory` is the cap (max RAM the VM is allowed to use); `balloon` is the
    # floor the host can shrink it to when other VMs need RAM. Steady-state
    # usage for an ingress proxy is well under the balloon value; the gap
    # gives Proxmox room to absorb a failover from another node.
    memory = 2048;
    balloon = 768;
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
            size = "24";
            storage = "datapool";
            format = "raw";
            replicate = true;
            discard = true;
            serial = "rootdisk";
          };
        };
        virtio1 = {
          disk = {
            size = "16";
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
