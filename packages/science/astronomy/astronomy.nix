{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [

    #############
    # ASTRONOMY #
    #############
    pkgs.celestia
    pkgs.kstars
    #pkgs.gpredict
    pkgs.gpredict-unstable
    pkgs.astroterm

  ];
}
