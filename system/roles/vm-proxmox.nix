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

  # Optional data disk using stable by-id path; set disk serial in Proxmox (e.g., "data")
  fileSystems."/data" = {
    # You have to order the new data disk as SECOND so it will be scsi1 instead of scsi0
    device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi1";
    fsType = "ext4";
    autoFormat = true; # avoid mkfs on existing disks during switch
    options = [
      "defaults"
      "nofail"                  # do not fail boot if disk absent
      "noauto"                  # don't try to mount automatically on switch
      "x-systemd.automount"     # mount on first access instead
      "x-systemd.device-timeout=1s"
    ];
    neededForBoot = false;
  };

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
      availableKernelModules = [ "9p" "9pnet_virtio" "ata_piix" "uhci_hcd" "virtio_blk" "virtio_mmio" "virtio_net" "virtio_pci" "virtio_scsi" "virtio_serial" ];
      kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" "virtio_serial" ];
    };

    tmp.cleanOnBoot = true;
  };


}