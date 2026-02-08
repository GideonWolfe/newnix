{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  # Simple stylix configuration with sensible defaults
  stylix = {
    # Enable stylix at the SYSTEM level
    enable = true;
    
    # Theme configuration
    image = "${inputs.wallpapers}/wallpapers/topo.jpg";
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    
    # Opacity settings
    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 1.0;
    };
    
    # Cursor theme
    cursor = {
      package = pkgs.catppuccin-cursors.mochaDark;
      name = "catppuccin-mocha-dark-cursors";
      size = 32;
    };
    
    # Font configuration
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font";
      };
      serif = {
        package = pkgs.nerd-fonts.hack;
        name = "Hack Nerd Font";
      };
      sizes = {
        applications = 15;
        terminal = 12;
        desktop = 13;
        popups = 8;
      };
    };

    icons = {
      enable = true;
      package = pkgs.libsForQt5.breeze-icons;
      dark = "breeze-dark";
      light = "breeze";
    };
    
    # System-level targets only
    targets = {
      plymouth.enable = false;
      # Enable GTK theming at system level
      gtk.enable = true;
      # BUG: The option `services.xserver.desktopManager.plasma5' can no longer be used since it's been removed build error
      qt.enable = false;
    };
  };
}