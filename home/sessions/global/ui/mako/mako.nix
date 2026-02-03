{ pkgs, lib, config, ... }:

with config.lib.stylix.colors.withHashtag;

{
  services.mako = {
    # disabling because ags does it
    enable = false;
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
