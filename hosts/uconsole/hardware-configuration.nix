{ pkgs, pkgs-unstable, config, inputs, lib, ... }:

{
  imports = [
    ./bootloader.nix
  ];
  boot = {
    #kernelPackages = inputs.nixpkgs-unstable.legacyPackages.aarch64-linux.linuxPackages_rpi4;
    kernelPackages = pkgs.linuxPackages_rpi4;

    loader = {
      grub.enable = false;
    };
  };
  fileSystems = {
    "/boot/firmware" = {
      label = "FIRMWARE";
    };
    "/" = {
      label = "NIXOS_SD";
      fsType = "ext4";
    };
  };
  hardware.enableAllHardware = lib.mkForce false;

  # TODO: eventually enable swap
  # Swap configuration (optional, but helpful for limited RAM)
  # swapDevices = [
  #   {
  #     device = "/swapfile";
  #     size = 1024; # 1GB swap
  #   }
  # ];
}
