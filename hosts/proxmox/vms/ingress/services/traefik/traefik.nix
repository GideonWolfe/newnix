{ pkgs, lib, config, ... }:

{
  imports = [
    # Define the traefik entrypoints
    ./entrypoints.nix

    # Get SSL for my services
    ./acme.nix

    # Enable the CrowdSec bouncer
    ./traefik-crowdsec.nix

    # One file per service
    ./services/jellyfin.nix
  ];

  # Open the FW for Traefik
  networking.firewall.allowedTCPPorts = [ 80 8080 443 ];

  services.traefik = {
    enable = true;

    # Traefik static configuration
    staticConfigOptions = {

      # Set Log Level (DEBUG works too)
      log.level = "ERROR";

      # Access log to be mounted in crowdsec container
      accesslog = { filepath = "/var/lib/traefik/logs/access.log"; };

      # Enable the dashboard
      api = {
        dashboard = true;
        insecure = true;
      };
    };

    # Route for traefik API
    dynamicConfigOptions.http.routers.api = {
      entrypoints = [ "traefik" ];
      rule = "PathPrefix(`/api/`)";
      service = "api@internal";
    };
  };
}
