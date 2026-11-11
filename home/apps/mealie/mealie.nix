{ config, lib, osConfig, pkgs, ... }:

let
  service = osConfig.custom.world.services.mealie;
  url = "${service.protocol}://${service.ip}:${toString service.port}/";
in
{
  imports = [ ../chromium/chromium.nix ];

  xdg.dataFile."icons/hicolor/512x512/apps/mealie.png".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/d767d7327db7f8ebd3715b552523f61889eea41c/png/mealie.png";
    hash = "sha256-Qq4G6bk7Z9evJA1INIbY4AoNvY9d7NDQeQjyrWo2jOo=";
  };

  xdg.desktopEntries.mealie = {
    name = "Mealie";
    comment = "Recipes and meal planning in a Chromium app window";
    exec = "${lib.getExe config.programs.chromium.package} --app=${url}";
    icon = "mealie";
    terminal = false;
    categories = [ "Utility" ];
  };
}
