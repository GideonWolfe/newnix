{ config, lib, pkgs, inputs, ... }:

{
  environment.systemPackages = [

    ###########
    # Finance #
    ###########
    pkgs.cointop # TUI Crypto price tracker
    pkgs.ticker
    pkgs.tickrs
    pkgs.gnucash # basic accounting software
    pkgs.wealthfolio # local finance/portfolio tracker
  ];
}
