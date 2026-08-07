{ config, ... }:
{
  services.prometheus = {
    # Do NOT run a full Prometheus server on every monitored host — the
    # central monitoring box scrapes these exporters. Enabling the server
    # here pulls the ~177 MiB prometheus package and runs a needless daemon.
    # The exporters below work independently of `services.prometheus.enable`.
    exporters = {
      node = {
        enable = true;
        port = 9100;
        enabledCollectors = [
          "systemd"
          "processes"
        ];
      };
      smartctl = {
        # Conditionally enable this if smartd is enabled
        enable = config.services.smartd.enable;
        port = 9101;
      };
    };
  };
}