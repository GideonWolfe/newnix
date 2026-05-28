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
    # Transport / collection agent that ships local logs into the
    # co-located Loki. Safe to include in the aggregator because no host
    # currently runs both this stack and the agent role at the same time.
    ./alloy/alloy.nix
    # Pre-wires the sops secrets the stack can consume (SMTP, admin
    # bootstrap, prometheus push basic-auth). Modules use hasSecret
    # guards, so missing entries in the encrypted yaml are a no-op.
    ./secrets/secrets_monitoring.nix
  ];
}
