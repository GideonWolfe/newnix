# Configure settings for Nix itself
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow packages not supported on system
  nixpkgs.config.allowUnsupportedSystem = true;

  # disable docs to speed builds
  documentation.nixos.enable = false;
}