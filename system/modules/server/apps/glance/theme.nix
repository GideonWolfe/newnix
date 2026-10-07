{ config, lib, pkgs, ... }:
let
  colors = config.lib.stylix.colors;
  palette = lib.filterAttrs
    (name: _: builtins.match "base0[0-9A-F]" name != null)
    colors.withHashtag;
  paletteCSS = lib.concatStringsSep "\n" (lib.mapAttrsToList
    (name: value: "--stylix-${name}: ${value};")
    palette);

  css = ''
    :root {
      /* Expose the complete palette for future custom widgets too. */
      ${paletteCSS}

      --color-background: var(--stylix-base00);
      --color-widget-background: var(--stylix-base01);
      --color-widget-background-highlight: var(--stylix-base02);
      --color-widget-content-border: var(--stylix-base02);
      --color-separator: var(--stylix-base02);
      --color-popover-background: var(--stylix-base01);
      --color-popover-border: var(--stylix-base03);

      --color-text-base: var(--stylix-base05);
      --color-text-paragraph: var(--stylix-base05);
      --color-text-highlight: var(--stylix-base06);
      --color-text-base-muted: var(--stylix-base04);
      --color-text-subdue: var(--stylix-base04);

      --color-primary: var(--stylix-base0D);
      --color-positive: var(--stylix-base0B);
      --color-negative: var(--stylix-base08);
      --color-warning: var(--stylix-base0A);
      --color-progress-border: var(--stylix-base02);
      --color-progress-value: var(--stylix-base0D);
      --color-vertical-progress-value: var(--stylix-base0D);
      --color-graph-gridlines: var(--stylix-base02);
    }

    ::selection {
      background-color: var(--stylix-base02);
      color: var(--stylix-base06);
    }

    * {
      scrollbar-color: var(--stylix-base03) var(--color-background);
    }

    .bookmarks-link:visited {
      color: var(--stylix-base0E);
    }

    .bookmarks-link:hover,
    .bookmarks-link:focus-visible {
      color: var(--stylix-base0C);
    }

    .bookmarks-icon-container,
    .bookmarks-icon {
      opacity: 1;
    }

    .popover-frame {
      --shadow-color: color-mix(in srgb, var(--stylix-base00) 70%, transparent);
    }
  '';
in
{
  stylix.targets.glance = {
    enable = true;
    # The native target reads RGB channels; remap its slots to blue/green/red.
    colors.override = lib.concatMapAttrs (slot: source:
      lib.listToAttrs (map (channel: {
        name = "${slot}-rgb-${channel}";
        value = colors."${source}-rgb-${channel}";
      }) [ "r" "g" "b" ])
    ) {
      base05 = "base0D";
      base01 = "base0B";
      base04 = "base08";
    };
  };

  services.glance.settings = {
    server.assets-path = toString (pkgs.writeTextDir "stylix.css" css);
    branding.app-background-color = palette.base00;
    theme = {
      # Keep saved browser presets from overriding the host's Stylix theme.
      disable-picker = true;
      custom-css-file = "/assets/stylix.css";
    };
  };
}