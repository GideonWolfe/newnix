{ config, lib, pkgs, ... }:

let
  hackernews-tui = pkgs.callPackage ../custom/hackernews-tui.nix { };
in
{
  environment.systemPackages = [
    ################
    # Social Media #
    ################
    # BUG tuba compiling from scratch, takes forever
    #pkgs.tuba # GTK fediverse/mastadon client
    hackernews-tui
    pkgs.castero # TUI podcast player
  ];
}
