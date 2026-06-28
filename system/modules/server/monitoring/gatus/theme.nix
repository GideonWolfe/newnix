{ config, ... }:

# The "how it looks" half of the Gatus module. Generates a custom-css theme
# from the system stylix (base16) palette and feeds it to the dashboard via
# `ui.custom-css`, merging into the settings defined in ./gatus.nix.
#
# Layout styling sticks to the named selectors documented at
# https://gatus.io/docs/appearance. Gatus doesn't expose selectors for the
# health colors though, so for those we override its Tailwind utility classes
# directly - mapping red = down, green = up, yellow = degraded onto stylix.
let
  # Same helper homepage.nix uses: base16 colors with a leading `#`, ready to
  # drop into CSS. base00 = bg, base01 = surface, base02 = border, base05 = fg,
  # base08 = red, base0A = yellow, base0B = green.
  c = config.lib.stylix.colors.withHashtag;
in
{
  custom.monitoring.gatus.settings.ui.custom-css = ''
    /* --- Layout (documented selectors) --- */
    #global {
      background-color: ${c.base00};
      color: ${c.base05};
    }
    .dashboard-container {
      background-color: ${c.base00};
    }
    .endpoint,
    .endpoint-group,
    .announcement-container {
      background-color: ${c.base01};
      border: 1px solid ${c.base02};
    }
    .endpoint-header,
    .endpoint-group-header,
    .announcement-header {
      background-color: ${c.base01};
      color: ${c.base05};
    }
    .endpoint-content,
    .endpoint-group-content,
    .announcement-content {
      background-color: ${c.base01};
      color: ${c.base05};
    }

    /* --- Status colors (no named selectors, so override the utilities) --- */
    .bg-green-400,
    .bg-green-500,
    .bg-green-700 {
      background-color: ${c.base0B} !important; /* healthy */
    }
    .bg-red-400,
    .bg-red-500,
    .bg-red-700 {
      background-color: ${c.base08} !important; /* unhealthy */
    }
    .bg-yellow-400 {
      background-color: ${c.base0A} !important; /* degraded */
    }
    /* keep the interactive result bars distinguishable on hover */
    .hover\:bg-green-700:hover,
    .hover\:bg-red-700:hover {
      filter: brightness(0.85);
    }
  '';
}
