{
  resource.proxmox_vm_qemu.vm_ai = {
    name = "vm-ai";
    # CPU inference tower (Ryzen 9 7900X). Node name as it appears in the
    # cluster; confirm it matches `pvesh get /nodes` on the new box.
    target_node = "pvetower";
    vmid = 106;
    clone = "nixos-base";
    full_clone = true;
    tags = "prod,ai";

    # Auto-start on host boot so the VM recovers after a host reboot or an
    # OOM-kill of the kvm process.
    start_at_node_boot = true;

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";

    # 48 GiB pinned. Ballooning is disabled (balloon = 0): llama.cpp mmaps the
    # whole model into RAM and we want it hot and never reclaimed mid-inference.
    # Leaves ~13 GiB on the 61 GiB host for PVE + other guests.
    memory = 49152;
    balloon = 0;
    skip_ipv6 = true;

    cpu = {
      # `host` passes the raw Zen 4 feature set through (incl. AVX-512), which
      # llama.cpp's runtime CPU dispatch uses for a real speedup.
      type = "host";
      sockets = 1;
      # 20 of 24 threads; llama.cpp is memory-bandwidth bound, but the headroom
      # helps prompt processing. Pin --threads to 12 (physical cores) per model.
      cores = 20;
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
        # Root: OS, nix store, llama.cpp/llama-swap binaries. Rebuildable from
        # the flake, so not replicated.
        virtio0 = {
          disk = {
            size = "64G";
            storage = "datapool";
            format = "raw";
            replicate = false;
            discard = true;
            serial = "rootdisk";
          };
        };
        # Local GGUF cache (/data/ai/models). Mirrored from the NAS by
        # model-sync, so fully rebuildable -- NOT replicated or backed up.
        # NOTE: for fast model swaps this storage should be NVMe-backed.
        # 160 GiB holds several large quants (e.g. a 70B Q4 ~42 GiB plus a few
        # mid-size models); bump if you cache more simultaneously.
        virtio1 = {
          disk = {
            size = "160G";
            storage = "datapool";
            format = "raw";
            replicate = false;
            backup = false;
            discard = true;
            serial = "data";
          };
        };
      };
    };

    # See vm-ingress.nix for rationale -- silences Telmate's cosmetic
    # `startup_shutdown { -1 -> null }` non-diff.
    lifecycle = {
      ignore_changes = [ "startup_shutdown" ];
    };
  };
}
