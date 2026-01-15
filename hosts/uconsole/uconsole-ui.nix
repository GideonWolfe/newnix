{ pkgs, lib, inputs, config, ... }:

{

  # Rotate the screen for hyprland
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DSI-1, preferred, auto, 1, transform, 3" # 1x scale, rotate 270 degrees
    ];
  };

  # Override the scale settings for hyprpanel
  programs.hyprpanel.settings.theme = lib.mkForce {
      bar = {
        scaling = 65;
        dropdownGap = "1.4em";
        menus = {
          menu.notifications.scaling = 50;
          menu.power.scaling = 50;
          menu.dashboard.scaling = 43;
          menu.dashboard.confirmation_scaling = 50;
          menu.clock.scaling = 50;
          menu.battery.scaling = 50;
          menu.blutooth.scaling = 50;
          menu.network.scaling = 50;
          menu.volume.scaling = 50;
          menu.media.scaling = 50;
          tooltip.scaling = 50;
        };
        osd.scaling = 50;
        notification.scaling = 50;
      };
  };

}
