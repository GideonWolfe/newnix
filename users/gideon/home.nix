{ pkgs, inputs, ... }:

{
  home.username = "gideon";
  home.homeDirectory = "/home/gideon";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  imports = [
    # Import my core HM configs (shell stuff mostly) on every system
    ../../home/roles/core.nix
  ];
}