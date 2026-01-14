{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    gucharmap
    gnome-font-viewer
  ];
}
