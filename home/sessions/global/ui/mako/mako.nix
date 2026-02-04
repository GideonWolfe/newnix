{ pkgs, lib, config, ... }:

with config.lib.stylix.colors.withHashtag;

let
  hyprpanelEnabled = config.programs.hyprpanel.enable or false;
in
{
  # Note: disabling this only disables theming.
  # If a WM or other source runs mako, it will still function.
  # Consequently, it's OK to leave this enabled always, it won't conflict with other notifs
  services.mako = {
    # If enabled when hyprpanel is also enabled, rebuild error
    enable = lib.mkDefault (!hyprpanelEnabled);
    settings = {
      icons = true;
      text-color = base05;
      default-timeout = 10000; # 10 secs
    };
    extraConfig = ''
      [mode=do-not-disturb]
      invisible=1
    '';
  };
}
