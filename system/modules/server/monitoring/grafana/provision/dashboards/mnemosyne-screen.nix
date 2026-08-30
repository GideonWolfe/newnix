{ ... }:
{
  # Locally-authored NAS status dashboard. The JSON lives alongside this file
  # so edits made in Grafana's UI can be exported straight back into the repo.
  services.grafana.provision.dashboards.settings.providers = [{
    name = "mnemosyne-screen";
    options.path = ./mnemosyne-screen.json;
  }];
}
