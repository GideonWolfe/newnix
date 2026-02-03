{ pkgs, lib, config, ... }:
let
  # Prefer user-configured waybar package if set
  waybarCmd = lib.getExe (config.programs.waybar.package or pkgs.waybar);
in {
  # Base waybar settings and theme
  imports = [ ../global/ui/waybar/waybar.nix ];

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
  ];
}