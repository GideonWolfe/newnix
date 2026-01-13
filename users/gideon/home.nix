{ pkgs, ... }:

{
  home.username = "gideon";
  home.homeDirectory = "/home/gideon";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}