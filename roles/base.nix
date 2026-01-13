# This role is the base for all systems and imports common options
{
  imports = [
    # Basic nix settings
    ../modules/system/nix.nix
    # Home manager setup
    ../modules/system/home-manager.nix
    # Theme the system
    ../modules/system/stylix.nix
    # Enable fish shell
    ../modules/system/shell.nix
  ];
}