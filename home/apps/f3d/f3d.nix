{ pkgs, lib, config, ... }:

with config.lib.stylix.colors;

let
  # f3d expects colors as "R,G,B" decimal strings
  mkColor = r: g: b: "${r},${g},${b}";

  f3dConfig = [
    {
      options = {
        #HACK: docs say it's "background-color" but this is the only thing that works
        #BUG: bg-color and color don't look like my theme colors
        # Uncomment to add background image:
        # "hdri-file" = "${config.stylix.image}";
        "background-color" = mkColor base00-dec-r base00-dec-g base00-dec-b;
        "color"            = mkColor base0E-dec-r base0E-dec-g base0E-dec-b;
        "grid-color"       = mkColor base09-dec-r base09-dec-g base09-dec-b;
        "font-color"       = mkColor base05-dec-r base05-dec-g base05-dec-b;
        "x-color"          = mkColor base0B-dec-r base0B-dec-g base0B-dec-b;
        "y-color"          = mkColor base0D-dec-r base0D-dec-g base0D-dec-b;
        "z-color"          = mkColor base0A-dec-r base0A-dec-g base0A-dec-b;
        "anti-aliasing"    = true;
        "axis"             = true;
        "roughness"        = 0.2;
        "grid"             = true;
        "scalar-coloring"  = true;
      };
    }
  ];
in
{
  xdg.configFile.f3d = {
    enable = true;
    target = "f3d/config.json";
    text = builtins.toJSON f3dConfig;
  };
}
