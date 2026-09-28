{
  # vm-home-assistant (VMID 105)
  #
  # This VM predates Terranix management and was created/maintained by hand in
  # Proxmox. This resource is written to MATCH the existing live VM so it can be
  # adopted into Terraform state with `tofu import` WITHOUT recreating it:
  #
  #   nix build .#terranix_proxmox
  #   cd <generated dir> && tofu import proxmox_vm_qemu.vm_home_assistant pve2/qemu/105
  #   tofu plan   # iterate on this file until the plan shows NO changes
  #
  # Only apply once the plan is clean. The EFI/disk blocks are the fiddly part:
  # the live disks are datapool:vm-105-disk-2 (efidisk0) and datapool:vm-105-disk-3
  # (scsi0) after earlier migrations, so slot/size must line up. Confirm against
  # `qm config 105` on the node that currently owns it before importing.
  resource.proxmox_vm_qemu.vm_home_assistant = {
    name = "home-assistant";
    # Design intent: pve2 primary, pve3 failover. If the live VM is currently on
    # a different node at import time, import at its real node id, then relocate
    # to pve2 via `ha-manager crm-command relocate vm:105 pve2` afterwards.
    target_node = "pve2";
    vmid = 105;

    # Existing VM: NOT a clone. Do not set `clone`/`full_clone` or Terraform
    # would try to recreate it.
    tags = "prod,app";

    # Start after a node reboot; onboot alone does not recover a crashed VM.
    start_at_node_boot = true;
    # HA-managed: cold-restarts on its failover node (pve3) if pve2 fails.
    # Strict node-affinity rule (pve2 primary, pve3 failover) applied via
    # `ha-manager rules add` — see hosts/proxmox/README.md.
    hastate = "started";

    # UEFI guest (Home Assistant OS). Matches live `bios: ovmf`.
    bios = "ovmf";
    agent = 1;
    scsihw = "virtio-scsi-single";
    os_type = "ubuntu";

    # Boot from the scsi0 root disk only. The live VM's boot order was
    # `order=scsi0;ide2;net0`, but Terraform removes the empty ide2 cdrom; if
    # the boot order still referenced ide2, Proxmox rejects the update with
    # "invalid bootorder: device 'ide2' does not exist". Pin scsi0 so the
    # cdrom removal and boot order stay consistent.
    boot = "order=scsi0";

    # 4 GiB cap with a 2 GiB balloon floor. Floor only bites during a transient
    # failover overcommit; steady state runs at the full 4 GiB.
    memory = 4096;
    balloon = 2048;
    skip_ipv6 = true;

    cpu = {
      type = "host";
      sockets = 1;
      cores = 2;
    };

    # Preserve the existing MAC so DHCP reservations / firewall rules keep
    # working. Matches live `net0: virtio=BC:24:11:B0:87:01,bridge=vmbr0,firewall=1`.
    network = [
      {
        model = "virtio";
        macaddr = "BC:24:11:B0:87:01";
        bridge = "vmbr0";
        firewall = true;
        id = 0;
      }
    ];

    # EFI vars disk. Matches live efidisk0 (efitype 4m, pre-enrolled keys).
    efidisk = {
      efitype = "4m";
      storage = "datapool";
      pre_enrolled_keys = true;
    };

    # Root disk on SCSI with iothread. Matches live scsi0 (32G, iothread=1).
    disks = {
      scsi = {
        scsi0 = {
          disk = {
            size = "32G";
            storage = "datapool";
            format = "raw";
            replicate = true;
            discard = true;
            iothread = true;
          };
        };
      };
    };

    # This VM was IMPORTED, not created by Terraform, so several attributes that
    # only matter at creation time (or that the provider can't round-trip from
    # an import) would otherwise force a destroy/recreate. Ignore them so the
    # plan converges without replacing the running guest:
    #   - full_clone: schema default (true) vs imported state (false) → ForceNew
    #   - clone:      not applicable to an imported VM
    #   - efidisk:    import doesn't populate the block; re-declaring it ForceNew
    #   - startup_shutdown/qemu_os: cosmetic Telmate non-diffs
    # The efidisk/scsi0 disks already exist on datapool and are left as-is.
    lifecycle = {
      ignore_changes = [
        "startup_shutdown"
        "qemu_os"
        "full_clone"
        "clone"
        "efidisk"
      ];
    };
  };
}
