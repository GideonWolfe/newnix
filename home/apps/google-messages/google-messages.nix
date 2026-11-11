{ config, lib, pkgs, ... }:

{
  imports = [ ../chromium/chromium.nix ];

  xdg.dataFile."icons/hicolor/512x512/apps/google-messages.png".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/homarr-labs/dashboard-icons/d767d7327db7f8ebd3715b552523f61889eea41c/png/google-messages.png";
    hash = "sha256-4iYLeHaXNT/KXPms/gYT31MjOwD4k5QJDlXS9zS8TbA=";
  };

  xdg.desktopEntries.google-messages = {
    name = "Google Messages";
    comment = "Text messages in a Chromium app window";
    exec = "${lib.getExe config.programs.chromium.package} --app=https://messages.google.com/web/";
    icon = "google-messages";
    terminal = false;
    categories = [ "Network" "Chat" ];
  };
}
