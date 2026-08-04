{ pkgs, lib, inputs, config, ... }:

{
  # Hyprland monitor settings
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # DP-1 is portrait (rotated) on the far left, DP-2 middle, DP-3 right
      "DP-1, preferred, 0x0, 1, transform, 3"
      "DP-2, preferred, 1440x678, 1"
      "DP-3, preferred, 4000x678, 1"
    ];
    workspace = [
      "1, monitor:DP-3, default:true"
      "2, monitor:DP-3, default:true"
      "3, monitor:DP-3, default:true"
      "4, monitor:DP-2, default:true"
      "5, monitor:DP-2, default:true"
      "6, monitor:DP-2, default:true"
      "7, monitor:DP-2, default:true"
      "8, monitor:DP-1, default:true"
      "9, monitor:DP-1, default:true"
      "10, monitor:DP-1, default:true"
    ];
  };
  # Niri monitor settings to mirror the Hyprland layout.
  # DP-1 is portrait (rotation 270 = "90 CCW") on the far left, then DP-2, DP-3.
  programs.niri.settings.outputs = lib.mkForce {
    "DP-1" = {
      mode = { width = 2560; height = 1440; refresh = 143.999; };
      position = { x = 0; y = 0; };
      scale = 1.0;
      transform = { rotation = 90; };
    };
    "DP-2" = {
      mode = { width = 2560; height = 1440; refresh = 143.999; };
      position = { x = 1440; y = 678; };
      scale = 1.0;
    };
    "DP-3" = {
      mode = { width = 2560; height = 1440; refresh = 143.999; };
      position = { x = 4000; y = 678; };
      scale = 1.0;
    };
  };
  # Override the scale settings for hyprpanel
  programs.hyprpanel.settings.theme = lib.mkForce {
      bar = {
        scaling = 70;
        dropdownGap = "2.1em";
        menus = {
          menu.notifications.scaling = 70;
          menu.power.scaling = 70;
          menu.dashboard.scaling = 65;
          menu.dashboard.confirmation_scaling = 70;
          menu.clock.scaling = 70;
          menu.battery.scaling = 70;
          menu.blutooth.scaling = 70;
          menu.network.scaling = 70;
          menu.volume.scaling = 70;
          menu.media.scaling = 70;
          tooltip.scaling = 70;
        };
        osd.scaling = 70;
        notification.scaling = 70;
      };
  };
  # Configure hyprpanel for different bars on each monitor
  programs.hyprpanel.settings."bar.layouts" = lib.mkForce {
    # Right monitor
    "0" = {
      left = [ "dashboard" "workspaces" ];
      middle = [ "media" ];
      right =
        [ "volume" "network" "bluetooth" "systray" "hypridle" "notifications" ];
    };
    # Middle monitor
    "1" = {
      left = [ "dashboard" "workspaces" ];
      middle = [ "media" ];
      right = [ "volume" "clock" "notifications" ];
    };
    # Left monitor
    "2" = {
      left = [ "dashboard" "workspaces" ];
      middle = [ "media" ];
      right = [ "volume" "clock" "notifications" ];
    };
  };
}
