{ config, lib, ... }:
{
  imports = [ ./theme.nix ];

  services.glance = {
    enable = true;
    openFirewall = false;
    # Default individual values so theme contributions don't replace the entire config.
    settings = lib.mapAttrsRecursive (_: value: lib.mkDefault value)
      (import ./settings.nix { world = config.custom.world; });
  };
}