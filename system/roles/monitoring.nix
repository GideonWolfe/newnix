# This role can be cleanly imported into any configuration that I want to monitor with my main monitoring stack
{
  imports = [
    ../modules/monitoring/prometheus.nix
    ../modules/monitoring/alloy.nix
  ];
}

