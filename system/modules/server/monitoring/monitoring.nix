{
  imports = [
    # Status page / uptime dashboard.
    ./gatus
    # Metrics Server
    ./prometheus/prometheus.nix
    # Logs Server
    ./loki/loki.nix
    # Traces Server: Tempo removed — it was unused ("not really used lol")
    # and its WAL/compaction added needless write load to the root disk that
    # was helping saturate the VM. Re-add ./tempo/tempo.nix (and the Grafana
    # tempo datasource) if traces are ever actually needed.
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
