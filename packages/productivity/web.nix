{ config, lib, pkgs, inputs, ... }:
let
  basalt-tui = pkgs.callPackage ../custom/basalt-tui.nix { };
in {
  environment.systemPackages = [

    #######
    # Web #
    #######
    pkgs.chromium
    pkgs.w3m
    pkgs.qutebrowser
    pkgs.miniserve # serve startpage and other apps easily
    pkgs.amfora # TUI gemini browser
    pkgs.tor-browser
  ];
}
