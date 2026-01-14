{ config, lib, pkgs, ... }:

let
  hackernews-tui = pkgs.callPackage ../custom/hackernews-tui.nix { };
in
{
  environment.systemPackages = [
    pkgs.lyrebird # voice changer
    pkgs.slack
    pkgs.zoom-us
  ];
}
