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
  #virtualisation.libvirtd.enable = true;
  #virtualisation.spiceUSBRedirection.enable = true;

    # Enable docker daemon
  #virtualisation.docker.enable = true;
  # Choose docker as the backend for OCI containers configured via nix
  #virtualisation.oci-containers.backend = "docker";
}