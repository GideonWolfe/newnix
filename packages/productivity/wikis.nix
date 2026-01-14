{ config, lib, pkgs, inputs, ... }:
let
  basalt-tui = pkgs.callPackage ../custom/basalt-tui.nix { };
in {
  environment.systemPackages = [
    #########
    # Wikis #
    #########
    pkgs.trilium-desktop
    #pkgs.affine BUG: uses an insecure version of electron
    pkgs.obsidian
    basalt-tui
  ];
}
