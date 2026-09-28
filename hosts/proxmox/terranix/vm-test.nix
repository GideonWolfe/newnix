{
  resource.proxmox_vm_qemu.vm_test = {
    name = "vm-test";
    target_node = "pve3";
    vmid = 103;
    clone = "nixos-base";
    full_clone = true;
    tags = "test,app";

    # Start after a node reboot; onboot alone does not recover a crashed VM.
    start_at_node_boot = true;
    # HA-managed: cold-restarts on its failover node (pve2) if pve3 fails.
    # Strict node-affinity rule (pve3 primary, pve2 failover) applied via
    # `ha-manager rules add` — see hosts/proxmox/README.md.
    hastate = "started";

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    # 4 GiB cap with a 2 GiB balloon floor. Monitoring stack (Prometheus/Loki/
    # Tempo TSDB + Grafana) is page-cache-heavy and runs at the full 4 GiB
    # normally; the floor only applies during a transient failover overcommit.
    memory = 4096;
    balloon = 2048;
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
