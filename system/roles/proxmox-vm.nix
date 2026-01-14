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
}