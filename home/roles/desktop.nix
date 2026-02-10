{ inputs, lib, ... }:
# This role sets up all the UI and desktop configs
# Keybinds, themes, app launchers,etc
{
  imports = [
    #########################
    # Session level services #
    #########################
    ../sessions/global/udiskie.nix
    ../sessions/global/blueman-applet.nix
    ../apps/kdeconnect/kdeconnect.nix

    #############################
    # Desktop / UI configuration #
    #############################
    ../sessions/global/ui/stylix.nix
    ../sessions/global/ui/cursor.nix
    ../sessions/global/ui/gtk.nix
    ../sessions/global/ui/qt.nix
    ../apps/wofi/wofi.nix
    ../apps/kitty/kitty.nix
    ../apps/swappy/swappy.nix
    ../apps/fusuma/fusuma.nix
    ../apps/kando/kando.nix
    ../apps/clipse/clipse.nix

    # Hyprland stack
    ../sessions/hypr/hyprland.nix
    # TODO this should be able to be imported without consequence
    # Just finalizing how Niri handles DMS and other imports
    # For now import niri manually in the host config
    # Niri
    #../sessions/niri/niri.nix

    # Browser
    ../apps/firefox/firefox.nix
    ../apps/startpage/service.nix
    ../apps/darkreader/darkreader.nix
  ];
}
