{ pkgs, lib, config, ... }:

with config.lib.stylix.colors.withHashtag;

let
  json = pkgs.formats.json { };
  configData =  {
    schemeVersion = 0;
    enabled = true;
    fetchNews = true;
    theme = {
      mode = 1;
      brightness = 100;
      contrast = 100;
      grayscale = 0;
      sepia = 0;
      useFont = false;
      fontFamily = "Open Sans";
      textStroke = 0;
      engine = "dynamicTheme";
      stylesheet = "";
      # base00 to match the Firefox chrome; base01 became lighter than base00
      # after the base16 spec fix, which brightened web page backgrounds.
      darkSchemeBackgroundColor = base00;
      darkSchemeTextColor = base05;
      lightSchemeBackgroundColor = base05;
      lightSchemeTextColor = base00;
      scrollbarColor = "";
      selectionColor = "auto";
      styleSystemControls = false;
      lightColorScheme = "Default";
      darkColorScheme = "Default";
      immediateModify = false;
    };
    enabledByDefault = true;
    enabledFor = [];
    disabledFor = [];
    changeBrowserTheme = false;
    syncSettings = false;
    syncSitesFixes = false;
    # ability to program light/dark automation eventually
    # automation = {
    #   enabled = false;
    #   mode = "";
    #   behavior = "OnOff";
    # };
    # time = {
    #   activation = "18:00";
    #   deactivation = "9:00";
    # };
    # location = {
    #   latitude = null;
    #   longitude = null;
    # };
    previewNewDesign = false;
    previewNewestDesign = false;
    enableForPDF = true;
    enableForProtectedPages = false;
    enableContextMenus = false;
    detectDarkTheme = true;
  };
in
{
  # Current approach: generate a config.json that has to be imported into Dark
  # Reader by hand each time it changes.
  xdg.configFile.darkreader = {
    enable = true;
    # onChange = manually tell darkreader to refresh somehow?
    target = "darkreader/config.json";
    source = json.generate "darkreader-config.json" configData;
  };

  # Alternative (WIP): bake the settings straight into the Firefox profile so
  # they no longer need manual importing. Home Manager writes these into the
  # extension's storage, so Dark Reader picks them up on the next browser start.
  # Requires `extensions.force = true` on the profile (set in firefox.nix) and a
  # full browser restart after a rebuild to apply. Note: enabling this flips the
  # profile to the JSON storage backend, which resets extension state once (e.g.
  # a one-time Bitwarden re-login).
  # programs.firefox.profiles.default.extensions.settings."addon@darkreader.org".settings =
  #   configData;
}
