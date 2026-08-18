{ pkgs, lib, inputs, config, ... }:

{
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

}
