{ pkgs, ... }:
let
  dashboards = pkgs.fetchFromGitHub {
    owner = "rfmoz";
    repo = "grafana-dashboards";
    # master @ 2026-04-29 (upstream has no release tags)
    rev = "4b1729d13b610d449b1055659b070d28c19a9699";
    sha256 = "sha256-ub7UzZ3ixELZHC7pOiHMiH0ufAuFJwuGYIxoZ6rFiTM=";
  };
in {
  services.grafana.provision.dashboards.settings.providers = [{
    name = "node-exporter-full";
    options.path = "${dashboards}/prometheus/node-exporter-full.json";
  }];
}
