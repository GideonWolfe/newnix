{ config, lib, pkgs, inputs, ... }:

let
  gloomberb = pkgs.callPackage ../custom/gloomberg.nix { };
in
{
  environment.systemPackages = [

    ###########
    # Finance #
    ###########
    pkgs.cointop # TUI Crypto price tracker
    pkgs.ticker
    pkgs.tickrs
    pkgs.gnucash # basic accounting software
    pkgs.valuta # GTK currency converter 
    #pkgs.wealthfolio # local finance/portfolio tracker # BUILD ERROR
    gloomberb # Bloomberg-style terminal portfolio tracker
  ];
}
