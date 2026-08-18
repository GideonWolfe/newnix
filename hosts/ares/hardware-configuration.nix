{ config, lib, pkgs, modulesPath, ... }:

# Minimal hardware config for ares (Dell XPS 15 9510).
# Disko generates the fileSystems/swap config, so this file only carries the
# initrd kernel modules needed to see the NVMe drive at boot.
#
# `vmd` is essential: the XPS 15 9510 ships with the SSD controller in Intel
# RAID/VMD ("RAID On") mode, so the NVMe drive is invisible without it.
{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "vmd" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
