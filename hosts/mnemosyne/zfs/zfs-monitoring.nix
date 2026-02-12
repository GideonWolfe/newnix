{ lib, config, ... }:
{
  # NOTE this expects the core monitoring role is already enabled
  # Configure the ZFS exporter for prometheus
  services.prometheus.exporters.zfs = {
    enable = true;
    pools = [ "tank" ]; 
    #extraFlags = [];
  };

  # Append ZFS scrape job to the existing Alloy config provided by the monitoring role
  environment.etc."alloy/config.alloy".text = lib.mkAfter ''
    // Scrape ZFS metrics from the zfs_exporter
    prometheus.scrape "zfs_exporter" {
      // TODO finalize this
      targets = [
        {"__address__" = "localhost:${toString config.services.prometheus.exporters.zfs.port}", "job" = "zfs", "instance" = "${config.networking.hostName}:${toString config.services.prometheus.exporters.node.port}"},
      ]
      scrape_interval = "30s"
      forward_to = [prometheus.remote_write.default.receiver]
    }
  '';
}