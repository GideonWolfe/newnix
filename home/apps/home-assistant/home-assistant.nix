{ config, lib, osConfig, pkgs, ... }:

let
  service = osConfig.custom.world.services.home-assistant;
  url = "${service.protocol}://${service.ip}:${toString service.port}/";
in
{
  imports = [ ../chromium/chromium.nix ];

  xdg.dataFile."icons/hicolor/512x512/apps/home-assistant.png".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/d767d7327db7f8ebd3715b552523f61889eea41c/png/home-assistant.png";
    hash = "sha256-ZYL/8I23W1+xHVEzFFocAJ1fodaUB4kzCmOPI06FLL4=";
  };

  xdg.desktopEntries.home-assistant = {
    name = "Home Assistant";
    comment = "Home automation in a Chromium app window";
    exec = "${lib.getExe config.programs.chromium.package} --app=${url}";
    icon = "home-assistant";
    terminal = false;
    categories = [ "Utility" ];
  };
}
