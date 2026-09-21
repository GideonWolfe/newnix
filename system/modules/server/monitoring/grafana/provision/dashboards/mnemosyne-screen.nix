{ pkgs, ... }:
{
  # Locally-authored NAS status dashboard. The JSON lives alongside this file
  # so edits made in Grafana's UI can be exported straight back into the repo.
  services.grafana.provision.dashboards.settings.providers = [{
    name = "mnemosyne-screen";
    # File provisioning needs the resource envelope for a v2 dashboard spec.
    options.path = (pkgs.formats.json { }).generate "mnemosyne-screen.json" {
      apiVersion = "dashboard.grafana.app/v2";
      kind = "Dashboard";
      metadata.name = "agv29mj"; # Keep the existing NAS kiosk URL stable.
      spec = builtins.fromJSON (builtins.readFile ./mnemosyne-screen.json);
    };
  }];
}
