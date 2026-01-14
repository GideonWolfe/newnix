{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # Basic package set to enable playback of video content

    ###########
    # Players #
    ###########
    mpv
    mpvScripts.mpris # make mpv use mpris
    vlc

    ##############
    # Converters #
    ##############
    handbrake # GUI command is ghb
  ];
}
