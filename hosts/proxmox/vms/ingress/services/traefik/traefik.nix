{ pkgs, lib, config, ... }:

{
  imports = [
    # Define the traefik entrypoints
    ./entrypoints.nix

    # Get SSL for my services
    ./acme.nix

    # Enable the CrowdSec bouncer
    ./traefik-crowdsec.nix

    # Scrape traefik's /metrics into the central Prometheus via local Alloy
    ./traefik-monitoring.nix

    # One file per service
    ./services/jellyfin.nix
    ./services/navidrome.nix
    ./services/seerr.nix
    ./services/romm.nix
    ./services/mealie.nix
    ./services/karakeep.nix
    ./services/nextcloud.nix
    ./services/baikal.nix
    ./services/calibre-web-automated.nix
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

      # Expose Prometheus metrics on the built-in `traefik` entrypoint
      # (auto-created by `api.insecure`, listens on :8080). Scraped by
      # the local Alloy agent in ./traefik-monitoring.nix.
      metrics.prometheus = {
        addEntryPointsLabels = true;
        addServicesLabels = true;
        addRoutersLabels = true;
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
