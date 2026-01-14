{ config, lib, pkgs, inputs, ... }:
let
  basalt-tui = pkgs.callPackage ../custom/basalt-tui.nix { };
in {
  environment.systemPackages = [
    ########
    # News #
    ########
    pkgs.newsboat # TUI RSS reader
    #pkgs.akregator #Qt RSS reader
    pkgs.newsflash # GTK RSS reader
    pkgs.rssguard # KDE RSS reader
  ];
}
