# Nix module to use waybar with Hyprland if not using hyprpanel
{ pkgs, lib, config, ... }:
let
  # Prefer user-configured waybar package if set
  waybarCmd = lib.getExe (config.programs.waybar.package or pkgs.waybar);
in {
  # Base waybar settings and theme
  imports = [ ../global/ui/waybar/waybar.nix ];

  # Override the left modules to add hyprland-specific ones
  programs.waybar.settings.mainBar.modules-left = lib.mkAfter [
    "hyprland/workspaces"
    "hyprland/window"
    "hyprland/submap"
  ];

  # Start waybar with hyprland, keeping the core module WM-agnostic
  wayland.windowManager.hyprland.settings.exec-once = lib.mkAfter [
    "${waybarCmd} &"
  ];
}