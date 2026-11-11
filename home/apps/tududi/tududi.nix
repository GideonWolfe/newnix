{ config, lib, osConfig, pkgs, ... }:

let
  service = osConfig.custom.world.services.tududi;
  url = "${service.protocol}://${service.ip}:${toString service.port}/";
in
{
  imports = [ ../chromium/chromium.nix ];

  xdg.dataFile."icons/hicolor/512x512/apps/tududi.png".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/d767d7327db7f8ebd3715b552523f61889eea41c/png/tududi.png";
    hash = "sha256-Oabxt1jNLsenK+aBpLbf0i7leROm+PxfAqp5eO3szHs=";
  };

  xdg.desktopEntries.tududi = {
    name = "Tududi";
    comment = "Task management in a Chromium app window";
    exec = "${lib.getExe config.programs.chromium.package} --app=${url}";
    icon = "tududi";
    terminal = false;
    categories = [ "Office" "ProjectManagement" ];
  };
}
