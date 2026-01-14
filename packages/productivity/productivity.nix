{ config, lib, pkgs, inputs, ... }:
{
  environment.systemPackages = [

    #pkgs.kdePackages.umbrello # UML modeler


    #####################
    # Clocks and Timers #
    #####################
    pkgs.peaclock
    pkgs.mpris-timer # GTK Timer
    #pkgs.kronometer # ugly QT timer :(




    # GUI for weather
    pkgs.gnome-weather

    pkgs.sshs # TUI for opening SSH connections

    ###############
    # Downloaders #
    ###############
    pkgs.filezilla # FTP client
    pkgs.termscp # TUI FTP client
    pkgs.transmission_4-gtk # torrent client
    pkgs.webtorrent_desktop # stream torrents from the web
    pkgs.tartube-yt-dlp # GUI for youtube-dlp

    #######################
    # Encoding / Decoding #
    #######################
    pkgs.qrtool # encode/decode QR images
    pkgs.zint-qt # powerful barcode creator
    #pkgs.barcode # barcode generator
    #pkgs.zbar # barcode scanner

    #########
    # UTILS #
    #########
    #pkgs.gpick # color picker
    pkgs.translate-shell # google translate in the shell
    pkgs.dialect # GNOME GUI for translating
    pkgs.maim # scrot replacement
    pkgs.exhibit # GNOME 3D model viewer
    pkgs.chance # dice roller, binary name is rollit
    pkgs.kdePackages.kruler # Measure pixels on the screen
    pkgs.wofi-emoji # emoji selector


    # Dashboards
    pkgs.wtfutil
    pkgs.sampler


  ];
}
