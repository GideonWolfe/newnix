{
  resource.proxmox_vm_qemu.vm_app2 = {
    name = "vm-app2";
    target_node = "pve3";
    vmid = 104;
    clone = "nixos-base";
    full_clone = true;
    tags = "prod,app";

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
    # 8 GiB cap with a 4 GiB balloon floor. Page-cache-heavy (karakeep Next.js
    # + headless Chromium + Meilisearch, plus freshrss); runs at the full 8 GiB
    # normally. The floor only bites transiently during a failover overcommit,
    # keeping the VM alive (degraded) rather than OOM-killed.
    memory = 8192;
    balloon = 4096;
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
