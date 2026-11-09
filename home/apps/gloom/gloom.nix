{ lib, ... }:

{
  # Gloom currently supports only its bundled themes, not custom theme files.
  # Its Catppuccin Mocha palette matches this system's Stylix Base16 scheme.
  home.activation.gloomTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if command -v gloom >/dev/null 2>&1; then
      run gloom config set theme catppuccin
    fi
  '';
}
