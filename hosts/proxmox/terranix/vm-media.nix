{
  resource.proxmox_vm_qemu.vm_media = {
    name = "vm-media";
    target_node = "pve1";
    vmid = 102;
    clone = "proxmox-base";
    #clone = "nixos-base";
    full_clone = true;
    tags = "prod,app";

    bios = "seabios";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";
    # `memory` cap with `balloon` floor — 11 docker containers, mostly idle
    # but jellyfin metadata scans + nzbget par2/unrar can briefly use the
    # full 8 GiB. Balloon floor of 3 GiB keeps the working set hot and lets
    # the host reclaim the rest under pressure (e.g. a failover scenario).
    memory = 8192;
    balloon = 3072;
    skip_ipv6 = true;

    cpu = {
      type = "host";
      sockets = 1;
      # 4 cores: nzbget par2 verification and unrar are highly parallel,
      # and jellyfin's startup metadata scan benefits from extra threads.
      # Steady state CPU usage is low so the 4-core allocation is mostly
      # burst capacity, not sustained load.
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
        # Root: OS, nix store, docker images. Replicated so the VM survives
        # a node failure.
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
        # Configs: /data/<app>/config dirs (sonarr DB, jellyfin metadata,
        # nzbget settings, etc). Small, precious, replicated.
        virtio1 = {
          disk = {
            size = "32G";
            storage = "datapool";
            format = "raw";
            replicate = true;
            discard = true;
            serial = "data";
          };
        };
        # Scratch: nzbget downloads + soulseek staging. High churn, fully
        # rebuildable (re-download from indexer). NOT replicated — snapshots
        # on this volume are what broke datapool last time. Mounted inside
        # /data so service paths like /data/downloads/... keep working.
        virtio2 = {
          disk = {
            size = "80G";
            storage = "datapool";
            format = "raw";
            replicate = false;
            discard = true;
            serial = "scratch";
          };
        };
      };
    };
  };
}
