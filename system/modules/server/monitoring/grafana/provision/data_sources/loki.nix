{ config, ... }:
# Loki datasource for Grafana. Co-located, so localhost over plain HTTP.
{
  services.grafana.provision.datasources.settings.datasources = [
    {
      name = "Loki";
      type = "loki";
      uid = "loki";
      url = "http://localhost:${toString config.custom.world.services.loki.port}";
    }
  ];
}
