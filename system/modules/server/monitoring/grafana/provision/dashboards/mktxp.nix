{ pkgs, ... }:
let
  # The mktxp dashboard is only published on grafana.com (no upstream git
  # repo hosts the JSON), so we pull a pinned revision from the download API.
  # Bump `rev` and refresh the hash to update. https://grafana.com/grafana/dashboards/13679
  rev = 28;
  raw = pkgs.fetchurl {
    url = "https://grafana.com/api/dashboards/13679/revisions/${toString rev}/download";
    sha256 = "0005bqd36mk491rd4n38syx49230jqfxlalx9vkdynsw8pb124nm";
  };

  # The exported JSON references its datasource via the `${DS_PROMETHEUS}`
  # input placeholder, which provisioned dashboards don't resolve. Substitute
  # our real Prometheus datasource UID so every panel binds correctly.
  dashboard = pkgs.runCommand "mktxp-dashboard.json" { } ''
    ${pkgs.gnused}/bin/sed 's/''${DS_PROMETHEUS}/prometheus/g' ${raw} > $out
  '';
in {
  services.grafana.provision.dashboards.settings.providers = [{
    name = "mktxp";
    options.path = dashboard;
  }];
}
