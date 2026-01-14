{ config, lib, pkgs, ... }:

let
  hackernews-tui = pkgs.callPackage ../custom/hackernews-tui.nix { };
in
{
  environment.systemPackages = [
    ##########
    # Matrix #
    ##########
    pkgs.element-desktop # "official" Matrix GUI
    pkgs.fractal # GNOME Matrix GUI
    #gomuks # Matrix TUI #BUG: has a CSV
  ];
}
