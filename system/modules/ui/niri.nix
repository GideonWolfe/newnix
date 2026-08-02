{ inputs, ... }:
{
  # Upstream overlay so pkgs.niri-unstable exists system-wide
  # (declared here since home-manager uses useGlobalPkgs)
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  programs.niri = {
    # Enable Niri
    enable = true;
  };
}
