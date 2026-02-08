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
      darkSchemeBackgroundColor = base01;
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
  xdg.configFile.darkreader = {
    enable = true;
    # onChange = manually tell darkreader to refresh somehow?
    target = "darkreader/config.json";
    source = json.generate "darkreader-config.json" configData;
  };
}
