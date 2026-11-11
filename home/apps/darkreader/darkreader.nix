{ pkgs, lib, config, osConfig, ... }:

with config.lib.stylix.colors.withHashtag;

let
  json = pkgs.formats.json { };
  homeAssistant = osConfig.custom.world.services.home-assistant;
  # Developer overrides replace all built-in fixes, so retain a pinned baseline.
  upstreamFixes = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/darkreader/darkreader/dbf2a1029131280d9dab21ed29f1dfdeb51a6cc7/src/config/dynamic-theme-fixes.config";
    sha256 = "sha256-Iv2wIKjdun4fEFpTXtRLUyv2NRBITAa/CZnILloKwjo=";
  };
  dynamicThemeFixes = builtins.readFile upstreamFixes + ''

    ================================

    ${homeAssistant.ip}:${toString homeAssistant.port}

    CSS
    hui-view-background {
        background-color: ''${#fff} !important;
    }
  '';
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
  # Chromium still needs manual imports; Firefox uses the same settings below.
  xdg.configFile.darkreader = {
    enable = true;
    target = "darkreader/config.json";
    source = json.generate "darkreader-config.json" configData;
  };

  xdg.configFile."darkreader/dynamic-theme-fixes.config".text = dynamicThemeFixes;

  # Restart Firefox after rebuilding; extensions.force is set in firefox.nix.
  programs.firefox.profiles.default.extensions.settings."addon@darkreader.org".settings =
    lib.mkIf config.programs.firefox.enable (configData // {
      dev_dynamic_theme_fixes = dynamicThemeFixes;
    });
}
