{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # All other packages for video streaming, downloading, and editing video

    ###########
    # Editing #
    ###########
    footage # lightweight video editor with a few operations
    kdePackages.kdenlive # full video editor
    obs-studio
    obs-studio-plugins.obs-pipewire-audio-capture
    
    ################
    # Broadcasting #
    ################
    gnomecast # GTK client to chromecast local files

    ###########
    # Players #
    ###########
    jftui # Jellyfin TUI
    # Possibly using insecure QT library
    #jellyfin-media-player # official desktop client
    delfin # GTK Jellyfin client

    ###############
    # Downloaders #
    ###############
    yt-dlp # better youtube-dl
    vdhcoapp # companion for video downloader firefox plugin
    multiplex # watch torrents with your friends

    # Take photos through webcam
    cheese
    cameractrls
  ];
}
