# This role can be cleanly imported into any configuration that I want to monitor with my main monitoring stack
{ inputs, config, ... }:
{
  # imports = [
  # ];

  # Enable prometheus and the prometheus node exporter on the system
  services.prometheus = {
    enable = true;
    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "systemd"
          "processes"
        ];
      };
    };
  };

  # Configure Alloy to send the data to my central monitoring server
  services.alloy.enable = true;
  # TODO possibly break these out into individual files?
  # make the alloy config file, there is no module support yet
  environment.etc."alloy/config.alloy" = {
    text = ''
      // Prometheus remote write endpoint
      prometheus.remote_write "default" {
        endpoint {
          // Traefik handles routing/TLS; no explicit port
          url = "${config.custom.world.services.prometheus.protocol}://${config.custom.world.services.prometheus.domain}/api/v1/write"
        }
      }

      // Loki remote write endpoint
      loki.write "default" {
        endpoint {
          // Traefik handles routing/TLS; no explicit port
          url = "${config.custom.world.services.loki.protocol}://${config.custom.world.services.loki.domain}/loki/api/v1/push"
        }
      }

      // Scrape node metrics from node_exporter
      prometheus.scrape "node_exporter" {
        targets = [
          {"__address__" = "localhost:${toString config.services.prometheus.exporters.node.port}", "job" = "node", "instance" = "${config.networking.hostName}:${toString config.services.prometheus.exporters.node.port}"},
        ]
        scrape_interval = "15s"
        forward_to = [prometheus.remote_write.default.receiver]
      }

      // Optional: Scrape Alloy's own metrics
      prometheus.scrape "alloy" {
        targets = [
          {"__address__" = "localhost:12345", "job" = "alloy", "instance" = "${config.networking.hostName}:12345"},
        ]
        scrape_interval = "15s"
        forward_to = [prometheus.remote_write.default.receiver]
      }

      // Collect systemd journal logs
      loki.source.journal "journal" {
        max_age = "12h"
        labels = {
          job = "systemd-journal",
          host = "${config.networking.hostName}",
        }
        forward_to = [loki.write.default.receiver]
      }

      // Collect boot logs
      // BUG: needs root access for this
      loki.source.file "boot_logs" {
        targets = [
          {"__path__" = "/var/log/boot.log", job = "boot", host = "${config.networking.hostName}"},
        ]
        forward_to = [loki.write.default.receiver]
      }
    '';
  };

}

