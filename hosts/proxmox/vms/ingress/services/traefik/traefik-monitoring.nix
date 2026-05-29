# Scrapes Traefik's Prometheus metrics endpoint and ships them to the
# central Prometheus via the local Alloy agent (monitoring role).
# Assumes `metrics.prometheus` is enabled in traefik's static config.
{ lib, config, ... }:

let
  # `api.insecure = true` auto-creates the `traefik` entrypoint on :8080,
  # and `metrics.prometheus` (no entryPoint override) hangs off the same
  # one at /metrics.
  traefikMetricsPort = 8080;
in
{
  # Append Traefik scrape job to the existing Alloy config provided by the monitoring role
  environment.etc."alloy/config.alloy".text = lib.mkAfter ''
    // Scrape Traefik metrics from the built-in prometheus endpoint
    prometheus.scrape "traefik" {
      targets = [
        {"__address__" = "localhost:${toString traefikMetricsPort}", "job" = "traefik", "instance" = "${config.networking.hostName}:${toString traefikMetricsPort}"},
      ]
      scrape_interval = "30s"
      forward_to = [prometheus.remote_write.default.receiver]
    }
  '';
}
