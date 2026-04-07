{ pkgs, lib, config, ... }:

with config.lib.stylix.colors.withHashtag;

let
  editorTheme = {
    caret = {
      foreground = "${base05}";
      line-background = "${base01}";
      width = 2;
    };
    colors = {
      booleans = "${base0E}";
      comment = "${base04}";
      commentdoc = "${base04}";
      commentdockeyword = "${base08}";
      commentline = "${base04}";
      edge = "${base0E}";
      error-indicator = "${base08}55";
      error-indicator-outline = "${base08}";
      error-marker = "${base08}";
      functions = "${base0B}";
      keyword1 = "${base08}";
      keyword2 = "${base0C}";
      keyword3 = "${base0B}";
      keywords = "${base08}";
      margin-background = "${base00}";
      margin-foreground = "${base03}";
      matched-brace-background = "${base02}";
      matched-brace-foreground = "${base05}";
      models = "${base0C}";
      number = "${base0E}";
      operator = "${base08}";
      selection-background = "${base02}";
      selection-foreground = "${base05}";
      special-variables = "${base08}";
      string = "${base0A}";
      transformations = "${base0C}";
      unmatched-brace-background = "${base08}";
      unmatched-brace-foreground = "${base05}";
      variables = "${base05}";
      whitespace-foreground = "${base05}";
    };
    index = 2000;
    name = "Stylix";
    paper = "${base00}";
    text = "${base05}";
  };

  renderTheme = {
    colors = {
      axes-color = "${base04}";
      background = "${base00}";
      cgal-edge-2d = "${base0C}";
      cgal-edge-back = "${base0C}";
      cgal-edge-front = "${base0C}";
      cgal-face-2d = "${base0E}";
      cgal-face-back = "${base08}";
      cgal-face-front = "${base0E}";
      crosshair = "${base02}";
      opencsg-face-back = "${base08}";
      opencsg-face-front = "${base0E}";
    };
    index = 2000;
    name = "Stylix";
    show-in-gui = true;
  };

in {
  xdg.configFile."OpenSCAD/color-schemes/editor/stylix.json" = {
    text = builtins.toJSON editorTheme;
  };

  xdg.configFile."OpenSCAD/color-schemes/render/stylix.json" = {
    text = builtins.toJSON renderTheme;
  };
}
