# Configure settings for Nix itself
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow packages not supported on system
  nixpkgs.config.allowUnsupportedSystem = true;

  # disable docs to speed builds
  documentation.nixos.enable = false;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" "@wheel" ];
    warn-dirty = false;
  };
}