{ pkgs, ... }:
let
  dashboards = pkgs.fetchFromGitHub {
    owner = "traefik";
    repo = "traefik";
    # v3.7.1 (2026-05-13)
    rev = "fa49e2bcad7ffd8a80accdf1fae1ae480913d93d";
    sha256 = "sha256-fWZov19SHRhFdGJ6xgwP0qBtG7Oy9kDJJafDDKeGHws=";
  };
in {
  services.grafana.provision.dashboards.settings.providers = [{
    name = "traefik";
    options.path = "${dashboards}/contrib/grafana/traefik.json";
  }];
}
