{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    ##################
    # Virtualization #
    ##################
    qemu
    nemu # TUI for qemu
    bottles # Wine prefix manager GUI
    distrobox # container manager for dev environments
  ];
}
