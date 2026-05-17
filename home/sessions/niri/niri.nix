{ pkgs, lib, inputs, config, osConfig, ... }:
let
  niriPkg = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
in {
  imports = [
    inputs.niri.homeModules.niri
    inputs.niri.homeModules.stylix
    # Niri specific configs for waybar
    #./niri-waybar.nix
    # Mako since Niri doesn't ship a notification service
    #../global/ui/mako/mako.nix
    # Dank Material Shell
    ../global/ui/dms/dms.nix

    # Split niri config into focused files; each one extends
    # `programs.niri.settings` and is merged by the module system.
    ./input.nix
    ./layout.nix
    ./animations.nix
    ./binds.nix
    ./window-rules.nix
  ];

  # Keep upstream overlay so pkgs.niri-unstable exists
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  # https://github.com/sodiboo/niri-flake/blob/main/docs.md
  programs.niri = {
    enable = true;
    package = lib.mkDefault niriPkg;

    settings = {
      # Session/env basics
      environment = {
        "NIXOS_OZONE_WL" = "1";
        "QT_QPA_PLATFORM" = "wayland";
      };

      # Startup commands (runs after session start)
      spawn-at-startup = [
        # Set wallpaper
        { command = [ "${lib.getExe pkgs.swww}" "img" "${osConfig.stylix.image}" ]; }
      ];

      prefer-no-csd = true;
      clipboard.disable-primary = true;
      screenshot-path = "${config.xdg.userDirs.pictures}/screenshots/%Y-%m-%d %H-%M-%S.png";

      hotkey-overlay = {
          skip-at-startup = true;
          hide-not-bound = true;
      };
    };
  };
}
