{ pkgs, lib, config, ... }:

# Gatus - developer-oriented health dashboard / status page. It periodically
# probes each endpoint and evaluates a list of conditions (status code,
# connectivity, cert expiry, ...) to decide whether a service is healthy.
#
# Upstream:        https://github.com/TwiN/gatus
# Config docs:     https://github.com/TwiN/gatus#configuration
# Container image: ghcr.io/twin/gatus
# Internal port:   8080 (mapped to svc.port on the host)
#
# This file is the "how to run it" half:
#   * declares `custom.monitoring.gatus.settings`, a freeform attrset that is
#     rendered straight to Gatus' config.yaml (Gatus reads YAML, which is a
#     superset of JSON, so a Nix attrset maps cleanly onto it)
#   * sets the global (non-endpoint) settings here
#   * runs the container with that generated config bind-mounted in
#
# The "what to monitor" half - the endpoint list built from the `world`
# services - lives next door in ./endpoints.nix. Both contribute to the same
# `custom.monitoring.gatus.settings` option and the module system merges them.
let
  svc = config.custom.world.services.gatus;

  # Gatus' native config format is YAML; pkgs.formats gives us a typed,
  # mergeable option plus a generator that serialises the merged attrset.
  settingsFormat = pkgs.formats.yaml { };

  # The fully-merged settings (globals below + endpoints from ./endpoints.nix)
  # rendered to a single config.yaml in the nix store.
  configFile = settingsFormat.generate "gatus-config.yaml"
    config.custom.monitoring.gatus.settings;
in
{
  options.custom.monitoring.gatus.settings = lib.mkOption {
    type = settingsFormat.type;
    default = { };
    description = ''
      Freeform Gatus configuration. Merged across modules and rendered to the
      config.yaml mounted into the container. See
      https://github.com/TwiN/gatus#configuration for the full schema.
    '';
  };

  config = {
    # Global, non-endpoint settings. The list of services to monitor is kept
    # separate in ./endpoints.nix so the "what" is decoupled from the "how".
    custom.monitoring.gatus.settings = {
      # In-memory storage keeps the module portable (no volume / tmpfiles),
      # but uptime history is wiped whenever the container restarts. To
      # persist it, switch to sqlite and add a `/data` volume below:
      #   storage = { type = "sqlite"; path = "/data/gatus.db"; };
      storage.type = "memory";

      metrics = true; # expose Prometheus metrics on /metrics

      ui = {
        title = "Status | gideonwolfe.xyz";
        header = "Homelab Status";
        "dashboard-heading" = "Service Health";
        "default-sort-by" = "group";
      };

      # If Gatus itself loses internet, skip checks instead of reporting a
      # wall of false negatives.
      connectivity.checker = {
        target = "1.1.1.1:53";
        interval = "60s";
      };
    };

    virtualisation.oci-containers.containers.gatus = {
      # Pin a released tag for reproducible rebuilds rather than :stable.
      # Tags: https://github.com/TwiN/gatus/pkgs/container/gatus
      image = "ghcr.io/twin/gatus:v5.36.0";
      autoStart = true;

      # Publish the host port (from world.services) to Gatus' internal :8080.
      ports = [ "${toString svc.port}:8080" ];

      environment = {
        TZ = "America/New_York";
      };

      volumes = [
        # Nix-generated config, mounted read-only. Gatus reads
        # /config/config.yaml by default.
        "${configFile}:/config/config.yaml:ro"
      ];
    };

    # Let the LAN (and traefik) reach the dashboard.
    networking.firewall.allowedTCPPorts = [ svc.port ];

    # Public route - only attaches on a host that actually runs traefik (same
    # guard grafana/prometheus use). On the sandboxed proxmox stack traefik
    # lives on vm-ingress, so to expose this publicly add a matching router in
    # hosts/proxmox/vms/ingress/services/traefik/services/ and point DNS at it.
    services.traefik.dynamicConfigOptions = lib.mkIf config.services.traefik.enable {
      http.routers.gatus = {
        entryPoints = [ "http" "https" ];
        rule = "Host(`${svc.domain}`)";
        service = "gatus";
        tls.domains = [ { main = "*.gideonwolfe.xyz"; } ];
        tls.certResolver = "myresolver";
      };
      http.services.gatus.loadBalancer = {
        passHostHeader = true;
        servers = [ { url = "http://${svc.ip}:${toString svc.port}"; } ];
      };
    };
  };
}
