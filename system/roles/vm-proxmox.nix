# Role designed to be imported by hosts running in proxmox
{ inputs, modulesPath, lib, ... }:
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

  # Ensure generated qcow images have enough room on first boot
  #virtualisation.diskSize = lib.mkDefault 30720; # MiB (≈30 GiB)

  #########
  # Disks #
  #########

  # Define root FS, this is the disk we already generated
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    autoResize = true;
    fsType = "ext4";
  };

  # Only mount /boot when using systemd-boot/EFI; skipped for legacy grub
  # fileSystems."/boot" = lib.mkIf config.boot.loader.systemd-boot.enable {
  #   device = "/dev/disk/by-label/ESP";
  #   fsType = "vfat";
  # };


  ##############
  # Bootloader #
  ##############
  boot = {
    growPartition = true;
    kernelParams = [ ];

    loader = {
      # Simplest/most portable: legacy BIOS + grub on disk MBR
      systemd-boot.enable = false;
      grub = {
        enable = true;
        device = "/dev/vda"; # whole disk for BIOS/MBR
        efiSupport = false;
      };
    };

    initrd = {
      availableKernelModules = [ "9p" "9pnet_virtio" "ata_piix" "uhci_hcd" "virtio_blk" "virtio_mmio" "virtio_net" "virtio_pci" "virtio_scsi" ];
      kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];
    };

    tmp.cleanOnBoot = true;
  };


}