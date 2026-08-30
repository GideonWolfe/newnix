{ ... }:
{
  # Locally-authored ZFS pool dashboard for soteria, the backup/replication
  # target. Scoped to soteria's node exporter and includes replication health.
  services.grafana.provision.dashboards.settings.providers = [{
    name = "soteria-tank";
    options.path = ./soteria-tank.json;
  }];
}
