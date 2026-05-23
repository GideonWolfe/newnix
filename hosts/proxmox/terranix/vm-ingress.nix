{
  resource.proxmox_vm_qemu.vm_ingress = {
    name = "vm-ingress";
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

    # Silence cosmetic drift from the Telmate provider. The provider stores
    # `-1` as an internal sentinel for "unset", Proxmox returns `null`, and
    # the resulting `startup_shutdown { order = -1 -> null }` shows up on
    # every plan even though nothing on the VM has actually changed.
    # See https://github.com/Telmate/terraform-provider-proxmox/issues for
    # the broader pattern. Add additional attributes here if more cosmetic
    # drift appears (e.g. `define_connection_info`, `qemu_os`).
    lifecycle = {
      ignore_changes = [ "startup_shutdown" ];
    };
  };
}
