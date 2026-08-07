{ config, lib, pkgs, ... }:

{
  # Container runtime — needed on every host, including headless app VMs
  # that run OCI/docker containers. Desktop-only VM tooling (libvirt,
  # virt-manager, SPICE) lives in modules/system/libvirt.nix and is
  # imported by the desktop role so servers don't pull in qemu.
  virtualisation = {
    docker.enable = true;
    oci-containers.backend = "docker";
  };
}