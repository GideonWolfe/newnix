# Role designed to be imported by hosts running in proxmox
{ inputs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Enable QEMU Guest Agent for better Proxmox integration
  services.qemuGuest = {
    enable = true;
  };

  # reduce size of the VM
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  #########
  # Disks #
  #########

  # Define root FS, this is the disk we already generated
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  # Mount the EFI System Partition
  # TODO: might not be needed depending on bootloader setpu
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
  };

  # Define and mount an additional data disk at /data
  # To be used if attaching additional disk to VM
  # Possibly should be added at a per-host level
  # Automatically format and mount the data disk
  # fileSystems."/data" = {
  #   device = "/dev/sdb";
  #   fsType = "ext4";
  #   autoFormat = true;  # Automatically format if not formatted
  #   options = [ "defaults" ];
  # };

  ##############
  # Bootloader #
  ##############
  # TODO: fix
  boot = {
    growPartition = true;
    #kernelModules = [ "kvm-amd" ];
    kernelParams = lib.mkForce [ ];

    loader = {

      efi.canTouchEfiVariables = lib.mkForce false;
      efi.efiSysMountPoint = "/boot";
      grub = {
        enable = true;
        device = "nodev";
        #device = "/dev/disk/by-label/ESP";
        efiSupport = true;
        efiInstallAsRemovable = true;
      };
      systemd-boot.enable = lib.mkForce false;
      # wait for 3 seconds to select the boot entry
      # timeout = lib.mkForce 3;
    };


    initrd = {
      availableKernelModules = [ "9p" "9pnet_virtio" "ata_piix" "uhci_hcd" "virtio_blk" "virtio_mmio" "virtio_net" "virtio_pci" "virtio_scsi" ];
      kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];
    };

    # clear /tmp on boot to get a stateless /tmp directory.
    tmp.cleanOnBoot = true;
  };


}