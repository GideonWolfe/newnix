{ lib, inputs, ... }:
  
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
  home-manager.users.gideon.imports = [
    # Only the basic configs
    ../../home/roles/core.nix
  ];

  # Point at the router
  networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "192.168.0.1" ];

  #########################
  # Proxmox image settings #
  #########################
  # These are used by the upstream proxmox-image module when building VM images
  proxmox = {
    # Simpler, legacy BIOS image (matches vm-proxmox role using grub/MBR)
    partitionTableType = "legacy";
    qemuConf = {
      name = "proxmox-base";
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

  # Disk size for generated images (MiB)
  virtualisation.diskSize = 30720;

  system.stateVersion = "25.11";
}
