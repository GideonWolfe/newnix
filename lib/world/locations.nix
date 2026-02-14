{ lib, ... }:
{
  options.custom.world.locations = {
    nyc = {
      lat = lib.mkOption {
        type = lib.types.float;
        default = 40.7128;
        description = "NYC Latitude";
      };
      long = lib.mkOption {
        type = lib.types.float;
        default = -74.0060;
        description = "NYC Longitude";
      };
    };
  };
}
