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

  # Root FS — uses the "nixos" label baked into the image by make-disk-image.nix.
  # No override needed; proxmox-image.nix already sets this to /dev/disk/by-label/nixos.


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
        device = "/dev/disk/by-id/virtio-rootdisk"; # stable serial-based path
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