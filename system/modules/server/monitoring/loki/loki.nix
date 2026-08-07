{
  lib,
  modulesPath,
  pkgs,
  config,
  ...
}:
{

  services.loki = {

    enable = true;

    configuration = {
      auth_enabled = false;

      server = {
        http_listen_port = config.custom.world.services.loki.port;
      };

      common = {
        ring = {
          instance_addr = "127.0.0.1";
          kvstore = {
            store = "inmemory";
          };
        };
        replication_factor = 1;
        path_prefix = "/var/lib/loki";
      };

      schema_config = {
        configs = [
          {
            from = "2020-05-15";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      storage_config = {
        filesystem = {
          directory = "/var/lib/loki/chunks";
        };
      };

      # Bound Loki's on-disk growth. Without a compactor + retention, the
      # chunk/index dirs under /var/lib/loki grow forever and every ingested
      # line is a permanent write — a big contributor to the root-disk I/O
      # saturation that stalls this VM. Keep 7 days and let the compactor
      # apply retention.
      limits_config = {
        retention_period = "168h"; # 7 days
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor";
        compaction_interval = "10m";
        retention_enabled = true;
        retention_delete_delay = "2h";
        # Required when retention is enabled with the filesystem backend.
        delete_request_store = "filesystem";
      };
    };
  };

  # Open firewall for Loki
  networking.firewall.allowedTCPPorts = [ config.custom.world.services.loki.port ];

  # Traefik routing for Loki (only when traefik is enabled on this host)
  services.traefik.dynamicConfigOptions = lib.mkIf config.services.traefik.enable {
    http.routers.loki = {
      rule = "Host(`${config.custom.world.services.loki.domain}`)";
      service = "loki";
      entryPoints = [
        "http"
        "https"
      ];
      tls.domains = [ { main = "*.gideonwolfe.xyz"; } ];
      tls.certResolver = "myresolver";
    };

    http.services.loki = {
      loadBalancer = {
        passHostHeader = true;
        servers = [
          {
            url = "http://${config.custom.world.services.loki.ip}:${toString config.custom.world.services.loki.port}";
          }
        ];
      };
    };
  };
}
