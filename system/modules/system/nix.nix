# Configure settings for Nix itself
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow packages not supported on system
  nixpkgs.config.allowUnsupportedSystem = true;

  # disable docs to speed builds and save disk
  # (man/info pages can pull a few hundred MB into the closure)
  documentation.nixos.enable = false;
  documentation.man.enable   = false;
  documentation.info.enable  = false;
  documentation.doc.enable   = false;

  # command-not-found pulls a sizeable channel index; servers don't need it
  programs.command-not-found.enable = false;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "@wheel" ];
      warn-dirty = false;
    };

    # Automatically garbage-collect old store paths. Without this the nix
    # store grows forever as you build new generations.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}