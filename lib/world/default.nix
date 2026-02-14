{ lib, config, ... }:
{
  imports = [
    ./locations.nix
    ./networks.nix
    ./hosts.nix
    ./services.nix
  ];
}
