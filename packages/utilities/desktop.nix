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

    # Flathub GUI
    bazaar

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
    thunar
    thunar-volman # allow thunar to manage removable drives
    thunar-archive-plugin
    thunar-media-tags-plugin # we have easytag for this but it doesn't hurt
    kdePackages.ark # advanced archive manager, haven't figured out KDE theming yet
    nautilus
    sushi # quick preview for nautilus
    tuifimanager # GUI like fm in the TUI

    #########################
    # File/Disk GUI tools   #
    #########################
    # Moved out of packages/utilities/files.nix so headless servers don't
    # pull in the GTK/GNOME stack.
    file-roller # archive utility
    czkawka # duplicate file finding GUI
    szyszka # bulk file renamer GUI
    clapgrep # GUI ripgrep
    gparted
    gnome-disk-utility
    baobab # disk usage analyzer GUI
    impression # GNOME util to quickly burn ISOs
    uefitool # GUI for manipulating and viewing UEFI firmware files

    #########################
    # Viewers / misc        #
    #########################
    # Moved out of base package lists: these pull heavy graphics/audio
    # stacks (VTK/OpenUSD, mbrola voices) not wanted on headless servers.
    f3d # lightweight 3D model viewer
    espeak # pipe script output to voice

    #########################
    # Dev / provisioning    #
    #########################
    # runtime formatters; opentofu is only needed on the workstation that
    # provisions Proxmox VMs. Kept off headless servers.
    opentofu # Terraform (used for provisioning Proxmox VMs)

    #########################
    # GUI monitors          #
    #########################
    # GUI hardware/kernel monitors moved out of packages/utilities/monitors.nix
    # so servers don't pull Qt/GTK/mesa.
    kernelshark # GUI kernel monitor
    cpupower-gui # GUI for tweaking CPU
    hardinfo2 # GUI for devices/hardware
    resources # hardware monitoring GUI
    flent # Advanced network tester CLI and GUI (pulls Qt5 + numpy/lapack)
    netperf # util to measure network performance (required by flent)
    http-getter # (required by flent)

    #########################
    # GUI networking        #
    #########################
    # Moved out of packages/utilities/networking.nix (GTK deps).
    networkmanagerapplet # GTK tray applet
    speedtest # GTK frontend for librespeed

    #################
    # Notifications #
    #################
    libnotify # provides notify-send and other utils
    fishPlugins.done # sends notification after cmd ends

    # Clocks
    gnome-clocks

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
