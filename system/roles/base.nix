# This role is the base for all systems and imports common options
{
  imports = [
    ###########
    # Modules #
    ###########
    # Import global world data
    ../../lib/world.nix
    # Basic nix settings
    ../modules/system/nix.nix
    # Home manager setup
    ../modules/system/home-manager.nix
    # Basic security services
    ../modules/system/security.nix
    # Theme the system
    ../modules/system/stylix.nix
    # Enable fish shell
    ../modules/system/shell.nix
    # Enable appimage support
    ../modules/system/appimage.nix

    ############
    # Packages #
    ############
    # General system utilities
  ../../packages/utilities/system.nix 
    # Command line utilities
  ../../packages/utilities/cli.nix
    # System monitors
  ../../packages/utilities/monitors.nix
    # Networking utilities
    ../../packages/utilities/networking.nix
  ];
}