{
  resource.proxmox_vm_qemu.vm_app1 = {
    name = "vm-app1";
    target_node = "pve2";
    vmid = 101;
    clone = "nixos-base";
    full_clone = true;
    tags = "prod,app";

    # Start after a node reboot; onboot alone does not recover a crashed VM.
    start_at_node_boot = true;
    # HA-managed: on node failure the CRM cold-restarts this VM on its failover
    # node (pve3). A strict node-affinity rule (pve2 primary, pve3 failover)
    # is applied via `ha-manager rules add` — see hosts/proxmox/README.md.
    hastate = "started";

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    # 16 GiB cap with a 10 GiB balloon floor. Page-cache-heavy (immich +
    # postgres); at steady state it runs at the full 16 GiB. The floor only
    # applies transiently when a failover overcommits the target node, letting
    # every VM stay running (degraded) instead of being OOM-killed. It must not
    # drop below the postgres/immich working set, hence 10 GiB not lower.
    memory = 16384;
    balloon = 10240;
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

    # See vm-ingress.nix for rationale — silences Telmate's cosmetic
    # `startup_shutdown { -1 -> null }` non-diff.
    lifecycle = {
      ignore_changes = [ "startup_shutdown" ];
    };
  };
}
