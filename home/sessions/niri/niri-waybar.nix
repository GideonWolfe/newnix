{ pkgs, lib, config, ... }:
let
  # Prefer user-configured waybar package if set
  waybarCmd = lib.getExe (config.programs.waybar.package or pkgs.waybar);
in {
  # Base waybar settings and theme
  imports = [ 
    ../global/ui/waybar/waybar.nix
    ../global/ui/mako/mako.nix
  ];

  # Override the left modules to add niri-specific ones
  programs.waybar.settings.mainBar.modules-left = lib.mkAfter [
    "niri/workspaces"
    "niri/mode"
    "niri/window"
    "niri/submap"
  ];

  # Start waybar with Niri, keeping the core module WM-agnostic
  programs.niri.settings.spawn-at-startup = lib.mkAfter [
    { command = [ waybarCmd ]; }
    # Other shells might handle notifications, so we don't want to start within niri globally
    # But if we're using waybar, we do need mako for notifications
    { command = [ "${pkgs.mako}/bin/mako" ]; }
  ];
}