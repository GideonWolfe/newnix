{ config, lib, pkgs, ... }:

let
  colors = config.lib.stylix.colors.withHashtag;
  toml = pkgs.formats.toml { };
in {
  # Set the default without making the app's saved radio settings read-only.
  home.activation.sdrtopTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target=${lib.escapeShellArg "${config.xdg.configHome}/sdrtop/config.toml"}
    run mkdir -p "$(dirname "$target")"
    if [ ! -f "$target" ]; then
      run touch "$target"
    fi
    run ${pkgs.yq}/bin/tomlq --toml-output --in-place '.theme.base = "stylix"' "$target"
  '';

  xdg.configFile."sdrtop/themes/stylix.toml".source =
    toml.generate "sdrtop-stylix.toml" (with colors; {
      name = "stylix";

      border_dim = base02;
      border_default = base03;
      border_accent = base0D;
      border_focused = base0E;
      label = base04;
      value = base05;
      value_hi = base0A;
      status_ok = base0B;
      status_warn = base09;
      status_crit = base08;
      peak_hold = base0E;
      noise_floor = base03;
      stale = base03;
      observer = base0C;
      net_ble = base0B;
      net_bt = base0E;
      series = [ base0D base09 base0B base0E base0C base08 base0A base0F ];

      # Weak signals fade into the terminal background; strong ones turn warm.
      palette = [
        {
          at = 0.0;
          color = base00;
        }
        {
          at = 0.15;
          color = base01;
        }
        {
          at = 0.30;
          color = base0D;
        }
        {
          at = 0.45;
          color = base0C;
        }
        {
          at = 0.60;
          color = base0B;
        }
        {
          at = 0.78;
          color = base0A;
        }
        {
          at = 0.90;
          color = base09;
        }
        {
          at = 1.0;
          color = base08;
        }
      ];
    });
}