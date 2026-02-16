{
  lib,
  modulesPath,
  pkgs,
  config,
  ...
}:
{

  networking.firewall.allowedTCPPorts = [ config.custom.world.services.grafana.port ]; # 3000 for Grafana

  services.grafana = {
    enable = true;

    # Not available yet, so done manually above
    #openFirewall = true;

    dataDir = config.custom.world.services.grafana.dataDir;

    # ONLY AVAILABLE IN UNSTABLE :()
    #declarativePlugins = with pkgs.grafanaPlugins; [
    #  grafana-piechart-panel
    #  grafana-worldmap-panel
    #  grafana-clock-panel
    #];

    settings = {

      smtp = {
        user = config.custom.world.email.infra_email.address;
        # TODO consolidate so it references the password for this email directly
        password = "$__file{${config.sops.secrets."grafana/smtp/password".path}}";
        host = "$__file{${config.sops.secrets."grafana/smtp/host".path}}";
      };

      server = {
        domain = config.custom.world.services.grafana.domain;
        http_port = config.custom.world.services.grafana.port;
        protocol = config.custom.world.services.grafana.protocol;
        http_addr = "0.0.0.0"; # Bind to all interfaces, not just localhost
      };

      users = {
        #password_hint = "its working hehe";
        password_hint = "$__file{${config.sops.secrets."grafana/hint".path}}";
        login_hint = "hello world";
        default_theme = "light";
      };

      security = {
        admin_user = "$__file{${config.sops.secrets."grafana/users/admin/username".path}}";
        admin_password = "$__file{${config.sops.secrets."grafana/users/admin/password".path}}";
        admin_email = "${config.custom.world.email.infra_email.address}";
      };

      # Reverse Proxy settings
    };

    provision = {
      # Declaring our Prometheus, Loki, and Tempo datasources
      datasources = {
        settings = {
          datasources = [
            {
              name = "Prometheus";
              type = "prometheus";
              uid = "prometheus";
              url = "${config.custom.world.services.prometheus.protocol}://localhost:${toString config.custom.world.services.prometheus.port}";

              # TODO testing
              jsonData = {
                basicAuth = true;
                basicAuthUser = "${config.sops.secrets."prometheus/push_user".value}";
                #basicAuthPassword = "${config.sops.secrets."prometheus/push_password".value}";
              };
              secureJsonData = {
                basicAuthPassword = "$__file{${config.sops.secrets."prometheus/push_password".path}}";
              };

            }
            {
              name = "Loki";
              type = "loki";
              uid = "loki";
              url = "${config.custom.world.services.loki.protocol}://localhost:${toString config.custom.world.services.loki.port}";
            }
            {
              name = "Tempo";
              type = "tempo";
              uid = "tempo";
              url = "${config.custom.world.services.tempo.protocol}://localhost:${toString config.custom.world.services.tempo.port}";
              jsonData = {
                tracesToLogs = {
                  datasourceUid = "loki";
                  tags = [
                    "job"
                    "host"
                  ];
                };
                tracesToMetrics = {
                  datasourceUid = "prometheus";
                  tags = [
                    {
                      key = "service.name";
                      value = "service";
                    }
                    { key = "job"; }
                  ];
                  queries = [
                    {
                      name = "Sample query";
                      query = "sum(rate(tempo_spanmetrics_latency_bucket{$$__tags}[5m]))";
                    }
                  ];
                };
                serviceMap = {
                  datasourceUid = "prometheus";
                };
                nodeGraph.enabled = true;
                search = {
                  hide = false;
                };
              };
            }
          ];
        };
      };
    };
  };

  # Traefik config to route traffic to Grafana
  services.traefik.dynamicConfigOptions.http.routers.grafana = {
    entryPoints = [
      "http"
      "https"
    ];
    rule = "Host(`${config.custom.world.services.grafana.domain}`)";
    service = "grafana";
    tls.domains = [ { main = "*.gideonwolfe.xyz"; } ];
    tls.certResolver = "myresolver";
  };

  services.traefik.dynamicConfigOptions.http.services.grafana = {
    loadBalancer = {
      passHostHeader = true;
      servers = [ { url = "http://${config.custom.world.services.grafana.ip}:${toString config.custom.world.services.grafana.port}"; } ];
    };
  };
}
