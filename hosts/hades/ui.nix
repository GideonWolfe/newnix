{ pkgs, lib, inputs, config, ... }:

{
  # Hyprland monitor settings
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-3, preferred, 0x0, 1"
      "DP-2, preferred, 2560x-25, 1"
      "DP-1, preferred, 5120x-335, 1, transform, 3"
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
}
