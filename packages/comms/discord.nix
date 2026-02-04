{ config, lib, pkgs, ... }:

let
  hackernews-tui = pkgs.callPackage ../custom/hackernews-tui.nix { };
in
{
  environment.systemPackages = [
    ###########
    # Discord #
    ###########
    pkgs.vesktop
    # takes forever to build
    #pkgs.dissent # GTK Discord client
  ];
}
