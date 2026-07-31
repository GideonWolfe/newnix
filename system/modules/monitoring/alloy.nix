{ config, lib, ... }:
let
  prom = config.custom.world.services.prometheus;
  loki = config.custom.world.services.loki;
  # Only scrape the smartctl exporter where it's actually enabled
  smartctl = config.services.prometheus.exporters.smartctl;
  # Talk to the stack directly over IP:port. The public Traefik-routed
  # `${protocol}://${domain}` only exists for hosts the ingress VM can
  # reach with valid TLS — the sandbox monitor (vm_test) doesn't have a
  # cert, so we bypass DNS/Traefik entirely on the LAN.
  promURL = "http://${prom.ip}:${toString prom.port}/api/v1/write";
  lokiURL = "http://${loki.ip}:${toString loki.port}/loki/api/v1/push";

  # S.M.A.R.T. disk metrics, only emitted where the smartctl exporter runs
  smartctlScrape = lib.optionalString smartctl.enable ''

      // Scrape S.M.A.R.T. disk metrics from smartctl_exporter
      prometheus.scrape "smartctl_exporter" {
        targets = [
          {"__address__" = "localhost:${toString smartctl.port}", "job" = "smartctl", "instance" = "${config.networking.hostName}:${toString smartctl.port}"},
        ]
        scrape_interval = "60s"
        forward_to = [prometheus.remote_write.default.receiver]
      }
  '';
in
{
  # Configure Alloy to send the data to my central monitoring server
  services.alloy.enable = true;
  # TODO possibly break these out into individual files?
  # make the alloy config file, there is no module support yet
  environment.etc."alloy/config.alloy" = {
    text = ''
      // Prometheus remote write endpoint (LAN, direct to monitor host)
      prometheus.remote_write "default" {
        endpoint {
          url = "${promURL}"
          basic_auth {
            username      = "push"
            password_file = "${config.sops.secrets."prometheus/push_password".path}"
          }
        }
      }

      // Loki remote write endpoint (LAN, direct to monitor host)
      loki.write "default" {
        endpoint {
          url = "${lokiURL}"
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
${smartctlScrape}
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