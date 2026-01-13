# This role can be cleanly imported into any desktop configuration to provide common desktop services.
# This means ANY system with a UI, whether it's a laptop, desktop, or VM.
{ pkgs, ... }:
{
  imports = [
    # Enable audio
    ../modules/system/pipewire.nix

    # Enable the boot splash and display manager
    ../modules/ui/plymouth.nix
    ../modules/ui/greeter.nix

    # Hyprland for our main window manager
    ../modules/ui/hyprland.nix
    # Other desktop glue
    ../modules/ui/xdg-portals.nix
  ];

  # Add packages essential for desktop functionality
  environment.systemPackages = with pkgs; [
    ###########
    # Theming #
    ###########
    # Icon themes
    papirus-icon-theme
    papirus-folders
    adwaita-icon-theme
    material-icons
    libsForQt5.breeze-icons
    # Qt theming tools
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    libsForQt5.qtcurve
    libsForQt5.qtstyleplugins
    # Additional theming tools
    spicetify-cli
  ];
}