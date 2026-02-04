{ config, lib, pkgs, ... }:

let
  hackernews-tui = pkgs.callPackage ../custom/hackernews-tui.nix { };
in
{
  environment.systemPackages = [
    ##########
    # Signal #
    ##########
    pkgs.signal-desktop
    pkgs.gurk-rs # signal TUI
    # TODO this is taking forever to compile?
    #pkgs.flare-signal # GNOME Signal GUI
  ];
}
