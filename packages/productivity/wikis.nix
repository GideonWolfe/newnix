{ config, lib, pkgs, inputs, ... }:
let
  basalt-tui = pkgs.callPackage ../custom/basalt-tui.nix { };
in {
  environment.systemPackages = [
    #########
    # Wikis #
    #########
    # BUG: trilium-desktop bundles EOL electron-40 (marked insecure in 26.05)
    #pkgs.trilium-desktop
    #pkgs.affine BUG: uses an insecure version of electron
    pkgs.obsidian
    basalt-tui
  ];
}
