{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [

    ###############
    # Linux Utils #
    ###############
    xdg-user-dirs # change default user directoryies
    xdg-utils


    ###########
    # Viewers #
    ###########
    imv # like mpv for images
    f3d # lightweight 3D model viewer

    lsof # List open files
    usbutils # adds utilities like lsusb
  ];
}
