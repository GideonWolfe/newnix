{ ... }:
{
  # Locally-authored ZFS pool dashboard for mnemosyne. Ported from the soteria
  # tank dashboard, scoped to mnemosyne's node exporter and dataset layout.
  services.grafana.provision.dashboards.settings.providers = [{
    name = "mnemosyne-tank";
    options.path = ./mnemosyne-tank.json;
  }];
}
