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
    # Timezone
    ../modules/system/timezone.nix
    # Network Manger
    ../modules/networking/network-manager.nix
    # Home manager setup
    ../modules/system/home-manager.nix
    # Basic security services
    ../modules/system/security.nix
    # Set up SOPS for the system
    ../modules/system/sops.nix
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
    ../../packages/utilities/files.nix 
    ../../packages/utilities/nix.nix 
    # Command line utilities
    ../../packages/utilities/cli.nix
    # System monitors
    ../../packages/utilities/monitors.nix
    # Networking utilities
    ../../packages/utilities/networking.nix
  ];
}