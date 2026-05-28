{ config, ... }:
# Tempo datasource for Grafana.
#
# Wired into the other two co-located datasources so traces can pivot
# into Loki logs / Prometheus metrics from the same UI:
#   - tracesToLogs   -> "loki" uid
#   - tracesToMetrics / serviceMap -> "prometheus" uid
# The string uids here must match the `uid` fields declared in
# loki.nix and prometheus.nix sibling files.
{
  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Tempo";
      type = "tempo";
      uid = "tempo";
      url = "http://localhost:${toString config.custom.world.services.tempo.port}";
      jsonData = {
        tracesToLogs = {
          datasourceUid = "loki";
          tags = [
            "job"
            "host"
          ];
        };
        tracesToMetrics = {
          datasourceUid = "prometheus";
          tags = [
            {
              key = "service.name";
              value = "service";
            }
            { key = "job"; }
          ];
          queries = [
            {
              name = "Sample query";
              query = "sum(rate(tempo_spanmetrics_latency_bucket{$$__tags}[5m]))";
            }
          ];
        };
        serviceMap = {
          datasourceUid = "prometheus";
        };
        nodeGraph.enabled = true;
        search = {
          hide = false;
        };
      };
    }
  ];
}
