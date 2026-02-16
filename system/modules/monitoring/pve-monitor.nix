# This is an exporter that collects proxmox PVE metrics
# Not to be run on the PVE itself, but another machine on the network
{
    # https://github.com/prometheus-pve/prometheus-pve-exporter
    services.prometheus.exporters.pve = {
        enable = true;
        port = 9102;
        # TODO add auth support for this, currently it only works if you have a user with no password and permissions to read the API
        environmentFile = ""; #TODO this should hold auth info
    };

  # Append PVE scrape job to the existing Alloy config provided by the monitoring role
  environment.etc."alloy/config.alloy".text = lib.mkAfter ''
    // Scrape PVE metrics from the pve_exporter
    prometheus.scrape "pve_exporter" {
      targets = [
        {"__address__" = "localhost:${toString config.services.prometheus.exporters.pve.port}", "job" = "pve", "instance" = "${config.networking.hostName}:${toString config.services.prometheus.exporters.pve.port}"},
      ]
      scrape_interval = "30s"
      forward_to = [prometheus.remote_write.default.receiver]
    }
  '';
}