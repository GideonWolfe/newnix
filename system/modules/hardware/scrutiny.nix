{ config, lib, pkgs, ... }:

{
  # Enable Scrutiny
  services.scrutiny = {
    enable = true;
    collector = { enable = true; };
    #influxdb = { enable = true; };
    settings = {
      web.listen = {
        port = 5232;
        # Bind on all interfaces so other devices on the LAN can reach
        # the web UI (default in scrutiny is 0.0.0.0, set explicitly).
        host = "0.0.0.0";
      };
    };
  };

  # Allow LAN access to the Scrutiny web UI.
  networking.firewall.allowedTCPPorts = [ 5232 ];
}
