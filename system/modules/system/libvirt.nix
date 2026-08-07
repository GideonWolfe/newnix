{ config, lib, pkgs, ... }:

{
  # Desktop/workstation virtualization tooling. Kept out of the base
  # virtualization module so headless server VMs don't pull in qemu and
  # the SPICE stack. Imported by the desktop role.
  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
  };
}
