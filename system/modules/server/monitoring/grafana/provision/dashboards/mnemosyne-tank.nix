{ pkgs, ... }:
{
  # Locally-authored ZFS pool dashboard for mnemosyne. Ported from the soteria
  # tank dashboard, scoped to mnemosyne's node exporter and dataset layout.
  services.grafana.provision.dashboards.settings.providers = [{
    name = "mnemosyne-tank";
    # File provisioning needs the resource envelope for a v2 dashboard spec.
    options.path = (pkgs.formats.json { }).generate "mnemosyne-tank.json" {
      apiVersion = "dashboard.grafana.app/v2";
      kind = "Dashboard";
      metadata.name = "mnemosyne-tank";
      spec = builtins.fromJSON (builtins.readFile ./mnemosyne-tank.json);
    };
  }];
}
