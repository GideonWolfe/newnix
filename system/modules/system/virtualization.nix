{ config, lib, pkgs, ... }:

{
  # Enable virt-manager
  programs.virt-manager.enable = true;

  virtualisation = {
    libvirtd.enable = true;
    spiceUSBRedirection.enable = true;
    docker.enable = true;
    oci-containers.backend = "docker";
  };
}