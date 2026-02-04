{ inputs, lib, ... }:
# Core user configuration I want on every system. Very lightweight.
# Automatically imported via users/gideon/default.nix
{
  imports =
    # Only inmport nixvim module and config if the input is available
    lib.optionals (inputs ? nixvim) [
      inputs.nixvim.homeModules.nixvim
      # we might want to import a lighter config on a per host basis
      #../apps/nixvim/nixvim.nix
    ]
    ++ [
      # Shells and terminal helpers
      ../apps/shell/fish.nix
      ../apps/shell/bash.nix
      ../apps/shell/starship.nix
      ../apps/zellij/zellij.nix
      ../apps/nh/nh.nix
      ../apps/zoxide/zoxide.nix
      ../apps/eza/eza.nix
      ../apps/bat/bat.nix
      ../apps/atuin/atuin.nix

      # Core environment configuration
      ../sessions/global/session-variables.nix
      ../sessions/global/xdg-user-dirs.nix
      ../sessions/global/mimetypes.nix
      ../apps/gpg/gpg.nix

      # Core applications/themes
      ../apps/btop/btop.nix
    ];
}
