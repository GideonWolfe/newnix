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

  # The upstream proxmox-image module adds `console=ttyS0` to kernelParams,
  # which makes NixOS auto-spawn serial-getty@ttyS0. These seabios/VGA VMs
  # have no real serial port, so agetty fails ("not a tty") and systemd
  # restart-loops it forever, flooding the journal. We access these VMs over
  # SSH / the Proxmox VGA console, so just disable the serial getty.
  systemd.services."serial-getty@ttyS0".enable = false;

  # reduce size of the VM
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # Cap persistent journal so logs can't fill the root disk.
  # Tweak SystemMaxUse to taste; 500M is plenty for a service VM.
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    SystemKeepFree=1G
    MaxRetentionSec=2week
  '';

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
    # Maybe disable to save CPU
    #kernelParams = [ "mitigations=off" ];

    loader = {
      # Simplest/most portable: legacy BIOS + grub on disk MBR
      systemd-boot.enable = false;
      grub = {
        enable = true;
        device = "/dev/disk/by-id/virtio-rootdisk"; # stable serial-based path
        efiSupport = false;
        # Keep only the last 5 generations in the boot menu. Old generations
        # still live in /nix/var/nix/profiles until `nix-collect-garbage`
        # runs, but the kernels won't all be retained in /boot.
        configurationLimit = 5;
      };
    };

    initrd = {
      availableKernelModules = [ "9p" "9pnet_virtio" "ata_piix" "uhci_hcd" "virtio_blk" "virtio_mmio" "virtio_net" "virtio_pci" "virtio_scsi" ];
      kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];
    };

    tmp.cleanOnBoot = true;
  };


}