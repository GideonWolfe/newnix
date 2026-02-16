{
  imports = [
    # Metrics Server
    ./prometheus/prometheus.nix
    # Logs Server
    ./loki/loki.nix
    # Traces Server (not really used lol)
    ./tempo/tempo.nix
    # Visualization Server
    ./grafana/grafana.nix
  ];
}
