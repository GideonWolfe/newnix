# Niri layout and overview configuration. Uses stylix-derived colors, so the
# `with config.lib.stylix.colors.withHashtag;` makes `base0X`, `blue`, `red`,
# etc. available throughout the file.
{ config, ... }:
with config.lib.stylix.colors.withHashtag;
{
  programs.niri.settings = {
    # Desktop layout
    layout = {
      gaps = 16;
      # Spacing around screen edges
      struts = {
        left = 64;
        right = 64;
      };

      # Give windows a border
      border = {
        enable = true;
        width = 2;
        # Subtle stylix-derived color for unfocused windows so they don't
        # fight the focus-ring gradient for attention.
        inactive.color = "${base02}";
      };

      # Give Windows a shadow
      shadow = {
        enable = true;
      };

      # Highlight around currently focused window
      focus-ring = {
        active = {
          gradient = {
            from = "${blue}";
            to = "${orange}";
            angle = 90;
            relative-to = "workspace-view";
            "in" = "oklch longer hue";
          };
        };
        # Muted ring on the last-focused window of *other* monitors.
        # Without this we'd inherit niri's default, which clashes with the
        # stylix palette on multi-monitor setups.
        inactive.color = "${base02}";
      };

      # Indicator above tabbed window columns
      tab-indicator = {
        # Draw tab indicators at top of column
        position = "top";
        # Don't draw if column not tabbed
        hide-when-single-tab = true;
        # Take up total length of tab proportional to window
        length.total-proportion = 1.0;
        # Small gap between tabs
        gaps-between-tabs = 10;
        # Color of actively focused tab
        active = {
          gradient = { from = "${base0A}"; to = "${base0E}"; angle = 45; };
        };
        # Color of tab when window is urgent
        urgent = {
          color = "${red}";
        };
      };

      # Hint when dragging windows in overview mode
      insert-hint = {
        display.gradient = {
          from = "${base0A}";
          to = "${base0E}";
          angle = 45;
          relative-to = "workspace-view";
        };
      };

      always-center-single-column = true;
      empty-workspace-above-first = true;
      default-column-display = "tabbed";
      # preset-column-widths = [ { proportion = 1.0 / 2.0; } { proportion = 1.0 / 3.0; } ];
      # Used when no wallpaper is set
      background-color = "${base00}";
    };

    overview = {
      zoom = 0.5;
      backdrop-color = "${base01}";
    };
  };
}
