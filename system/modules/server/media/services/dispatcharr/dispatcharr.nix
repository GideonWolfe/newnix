{ config, ... }:
let
  svc = config.custom.world.services.dispatcharr;
  dataDir = "/data/dispatcharr";
  port = toString svc.port;
in
{
  # Upstream AIO bundles PostgreSQL, Redis and Celery in the same container.
  virtualisation.oci-containers.containers.dispatcharr = {
    image = "ghcr.io/dispatcharr/dispatcharr:latest";
    autoStart = true;
    ports = [ "${svc.ip}:${port}:${port}" ];
    volumes = [ "${dataDir}:/data" ];
    extraOptions = [ "--network=media" ];
    environment = {
      DISPATCHARR_ENV = "aio";
      REDIS_HOST = "localhost";
      CELERY_BROKER_URL = "redis://localhost:6379/0";
      DISPATCHARR_LOG_LEVEL = "info";
      # Without a reverse proxy, advertised URLs must use the published port.
      DISPATCHARR_PORT = port;
    };
  };

  # Let the AIO entrypoint manage its internal service users and subdirectories.
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 root root - -"
  ];

  systemd.services.docker-dispatcharr = {
    after = [ "docker-create-media-network.service" ];
    requires = [ "docker-create-media-network.service" ];
    # Do not initialize a fresh database on the root disk if /data is absent.
    unitConfig.RequiresMountsFor = [ dataDir ];
  };

  networking.firewall.allowedTCPPorts = [ svc.port ];
}