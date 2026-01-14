{ config, lib, pkgs, ... }:

{
  # Enable Scrutiny
  services.scrutiny = {
    enable = true;
    collector = { enable = true; };
    #influxdb = { enable = true; };
    # Access at localhost:5232
    settings = { web = { listen = { port = 5232; }; }; };
  };
}
