{
  resource.proxmox_vm_qemu.vm_test = {
    name = "vm-test";
    target_node = "pve3";
    vmid = 103;
    clone = "nixos-base";
    full_clone = true;
    tags = "test,app";

    # Auto-start on host boot so the VM recovers after a host reboot or an
    # OOM-kill of the kvm process.
    start_at_node_boot = true;

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    # Ballooning DISABLED (balloon = 0): this VM runs the full monitoring
    # stack (Prometheus/Loki/Tempo TSDB + Grafana), which is page-cache
    # heavy. Same failure mode as vm-app1 — pvestatd auto-ballooning shrank
    # the guest during a host spike and never re-inflated it (hysteresis),
    # collapsing the page cache into an iowait pressure stall that starved
    # the shared datapool. Pin the full 4 GiB resident.
    memory = 4096;
    balloon = 0;
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
            discard = true;
            serial = "rootdisk";
          };
        };
        virtio1 = {
          disk = {
            size = "30G";
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
