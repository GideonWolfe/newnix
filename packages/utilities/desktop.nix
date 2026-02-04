{ config, lib, pkgs, inputs, ... }:

{
  # Utilities to have when running desktop environments
  environment.systemPackages = with pkgs; [
    #############
    # DBUS/logs #
    #############
    bustle # GTK app for viewing DBUS activity
    libsForQt5.qt5.qttools # toolset that includes qdbusviewer
    gnome-logs # GUI logfile viewer

    #################
    # App Launchers #
    #################
    wofi
    bemenu # like dmenu, required by sth
    kando # pie menu

    #############
    # Terminals #
    #############
    alacritty
    foot # default wayland/sway term
    kitty

    #################
    # File managers #
    #################
    ranger
    xfce.thunar
    xfce.thunar-volman # allow thunar to manage removable drives
    xfce.thunar-archive-plugin
    xfce.thunar-media-tags-plugin # we have easytag for this but it doesn't hurt
    kdePackages.ark # advanced archive manager, haven't figured out KDE theming yet
    nautilus
    sushi # quick preview for nautilus
    tuifimanager # GUI like fm in the TUI

    #################
    # Notifications #
    #################
    libnotify # provides notify-send and other utils
    fishPlugins.done # sends notification after cmd ends

    ###############
    # Screenshots #
    ###############
    swappy # screenshot GUI
    hyprshot # screenshot tool
    grimblast # hyprland screenshot helper

    #################
    # Wayland Utils #
    #################
    wev # wayland xev
    wlprop # wayland xprop
    evtest # event tester like wev but picks up things wev doesn't?
    ydotool # (wayland xdotool)
    wl-clipboard # wayland xclip
    wl-mirror # mirror wayland outptuts
    wdisplays
    wayland-utils
    slurp # select region in wayland compositor (like slop for X)
    wf-recorder # screen recorder util
    hyprpicker # wayland color picker
    libsForQt5.qt5.qtwayland # wayland compatibility


  ];
}
