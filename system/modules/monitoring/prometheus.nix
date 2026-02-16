{
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
      smartctl = {
        # Conditionally enable this if smartd is enabled
        enable = config.services.smartd.enable;
        port = 9101;
      };
    };
  };
}