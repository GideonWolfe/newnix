{ lib, ... }:
{
  # This file is for defining real-world network details.
  # Eventually I want this to be the source of truth,
  # and push settings to a router via terraform
  options.custom.world.networks = {
    home = {
      gateway = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.0.1";
          description = "The IP address of the home network gateway/router";
        };
      };
    };
  };
}
