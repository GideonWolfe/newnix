{ lib, inputs, config, ... }:
  
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/proxmox-image.nix"
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # Let's montior the VM
    ../../system/roles/monitoring.nix

    # Apply a system profile that matches this host
    #../../system/profiles/minimal.nix
    ../../system/profiles/proxmox-app-vm.nix

    # Let this VM mount the NAS NFS shares
    ../../system/modules/networking/mnemosyne-nfs.nix
  ];

  # Here we could add our full HM configuration (core is automatically imported)
  #home-manager.users.gideon.imports = [
    # Only the basic configs
  #  ../../home/roles/core.nix
  #];

  # Dropping some stuff to save space
  programs.appimage.enable = lib.mkForce false; # not needed on servers

  # These are headless VMs — no GUI to theme. Stylix's home-manager
  # integration otherwise generates a KDE/Qt theme (`stylix-kde-theme`,
  # ~600 MiB), pulls qtbase into the user environment, and sets a GNOME
  # dconf background whose `picture-uri` drags the entire ~600 MiB
  # wallpapers flake input into the closure. Disable the graphical HM
  # stylix targets to keep the closure lean.
  home-manager.users.gideon.stylix.targets = {
    kde.enable = false;
    qt.enable = false;
    gtk.enable = false;
    gnome.enable = false;
  };

  # Headless servers don't need geolocation-based timezone detection. The base
  # `automatic-timezoned` module runs geoclue plus a `geoclue-agent` *user*
  # service, which (along with gnome-keyring's gcr-ssh-agent) is desktop churn
  # that also makes home-manager's user-session dbus-broker reload fail during
  # `nixos-rebuild switch`. Use a static timezone instead — these VMs never move.
  services.automatic-timezoned.enable = lib.mkForce false;
  time.timeZone = "America/New_York";

  # Keep gideon's user systemd manager (and its session dbus-broker) running
  # persistently rather than being spun up transiently for each SSH+sudo switch.
  # Without this, home-manager's user activation reloads dbus-broker inside a
  # short-lived session and reports "user activation for gideon failed".
  users.users.gideon.linger = true;

  # Point at the router
  networking.defaultGateway = "${config.custom.world.hosts.router.ip}";
  networking.nameservers = [ "${config.custom.world.hosts.router.ip}" ];

  #########################
  # Proxmox image settings #
  #########################
  # These are used by the upstream proxmox-image module when building VM images
  proxmox = {
    # Simpler, legacy BIOS image (matches vm-proxmox role using grub/MBR)
    partitionTableType = "legacy";
    qemuConf = {
      name = "nixos-base";
      bios = "seabios";
      cores = 2;
      memory = 4096;
      # Primary disk (module only supports virtio0); virtio-scsi controller
      virtio0 = "datapool:vm-9999-disk-0";
      scsihw = "virtio-scsi-single";
      # Boot from the primary virtio disk
      boot = "order=virtio0";
      agent = true;
    };

    # Disable cloud-init for this image to avoid attempts to create a cloudinit disk on non-existent local-lvm
    cloudInit.enable = false;

    # Extra Proxmox config appended to qemu-server.conf inside the VMA
    # Proxmox will rewrite vm-9999 to the target VMID on restore
    # Declare a second disk here that we can use as a data disk; it will be created automatically by Proxmox if it doesn't exist
    #qemuExtraConf.scsi1 = "datapool:vm-9999-disk-1,size=23G,serial=data";
  };

  # Disk size for the generated VMA image (MiB).
  # This must satisfy two opposing constraints:
  #   1. Be large enough to hold the proxmox-base closure + ext4 overhead
  #      + boot partition. The build helper VM kernel-panics with init exit
  #      if `cp -a` of the closure runs out of room. Measure your closure
  #      with:
  #        nix path-info -Sh .#nixosConfigurations.proxmox-base.config.system.build.toplevel
  #      Rule of thumb: diskSize_GiB >= closure_GiB * 1.25 + 1.
  #   2. Be no larger than the smallest VM you ever want to clone from
  #      this template (terraform can grow zvols, never shrink them).
  # Currently sized to comfortably hold the full base+home-manager closure
  # (~14 GiB measured). If you trim the closure (drop stylix / HM / etc.
  # from server VMs), this can come down.
  virtualisation.diskSize = 24576; # 24 GiB

  system.stateVersion = "25.11";
}
