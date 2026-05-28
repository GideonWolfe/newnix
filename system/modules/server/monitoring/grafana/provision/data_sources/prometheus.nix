{ config, ... }:
# Prometheus datasource for Grafana.
#
# Co-located with Prometheus, so we talk to it over plain http on
# localhost. Prom's --web.config.file requires basic auth even for
# local queries, hence basicAuth below.
{
  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Prometheus";
      type = "prometheus";
      uid = "prometheus";
      # Force http here — the `protocol` field on the service options is
      # "https" because that's how *external* clients reach prom through
      # traefik. Grafana on the same box just hits the port directly.
      url = "http://localhost:${toString config.custom.world.services.prometheus.port}";

      basicAuth = true;
      basicAuthUser = "push";
      secureJsonData = {
        basicAuthPassword = "$__file{${config.sops.secrets."grafana/prometheus_push_password".path}}";
      };
    }
  ];
}
