{ config, lib, pkgs, inputs, ... }:
{
  environment.systemPackages = [


    #######################
    # Calendar / Contacts #
    #######################
    #pkgs.calcurse
    pkgs.calcure # modern calendar TUI
    pkgs.khal
    pkgs.gnome-calendar
    pkgs.gnome-contacts # contacts viewer that can connect to NC or Google
  ];
}
