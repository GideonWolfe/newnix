{ config, lib, pkgs, ... }:

let
  hackernews-tui = pkgs.callPackage ../custom/hackernews-tui.nix { };
in
{
  environment.systemPackages = [
    #######
    # IRC #
    #######
    pkgs.halloy # IRC GUI
    pkgs.weechat # IRC TUI
    pkgs.weechatScripts.weechat-notify-send # allow weechat to send notifications
    pkgs.weechatScripts.autosort
    pkgs.weechatScripts.highmon
  ];
}
