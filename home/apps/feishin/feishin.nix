{ pkgs, lib, config, ... }:

# Stylix theme for Feishin. Feishin (Electron desktop) reads custom themes from
# JSON files in ~/.config/feishin/Themes. We generate one from the base16 palette
# and let the user pick it under Settings → General → Theme ("Stylix").
# https://github.com/jeffvli/feishin/blob/development/docs/CUSTOM_THEMES.md
with config.lib.stylix.colors.withHashtag;

let
  theme = {
    mode = "dark";
    extends = "defaultDark";
    colors = {
      background = base00;
      background-alternate = base00;
      surface = base00;
      surface-foreground = base05;
      foreground = base05;
      foreground-muted = base04;
      primary = base0D;
      black = base00;
      white = base07;
      state-error = base08;
      state-info = base0D;
      state-success = base0B;
      state-warning = base0A;
    };
    # Force Mantine's primary/accent to follow the theme's primary color so the
    # accent tracks stylix even with "manual accent color" disabled.
    mantineOverride = {
      primaryColor = "primary";
      primaryShade = {
        dark = 6;
        light = 6;
      };
      colors = {
        primary = [
          base0D
          base0D
          base0D
          base0D
          base0D
          base0D
          base0D
          base0D
          base0D
          base0D
        ];
      };
    };
  };
in
{
  # feishin itself is installed via packages/music/music.nix
  home.file.".config/feishin/Themes/stylix.json".source =
    (pkgs.formats.json { }).generate "stylix.json" theme;
}
