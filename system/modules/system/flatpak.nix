# Allow the system to run flatpaks
{ pkgs, inputs, ... }:
let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
in
{
  services.flatpak.enable = true;
  # Pull flatpak from nixpkgs-unstable to pick up post-1.16.2 fixes
  # (NULL-deref in the dbus-proxy spawn path on stable 25.11)
  services.flatpak.package = pkgs-unstable.flatpak;
}