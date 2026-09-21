{ pkgs, ... }:
{
  # Locally-authored ZFS pool dashboard for soteria, the backup/replication
  # target. Scoped to soteria's node exporter and includes replication health.
  services.grafana.provision.dashboards.settings.providers = [{
    name = "soteria-tank";
    # File provisioning needs the resource envelope for a v2 dashboard spec.
    options.path = (pkgs.formats.json { }).generate "soteria-tank.json" {
      apiVersion = "dashboard.grafana.app/v2";
      kind = "Dashboard";
      metadata.name = "soteria-tank";
      spec = builtins.fromJSON (builtins.readFile ./soteria-tank.json);
    };
  }];
}
