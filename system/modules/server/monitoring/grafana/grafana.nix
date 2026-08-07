{
  lib,
  modulesPath,
  pkgs,
  config,
  ...
}:
{
  imports = [
    # Datasources are split per-backend; each file appends to
    # services.grafana.provision.datasources.settings.datasources.
    ./provision/data_sources/prometheus.nix
    ./provision/data_sources/loki.nix
    # Tempo datasource removed alongside the Tempo service (see monitoring.nix).
    # Re-add ./provision/data_sources/tempo.nix if Tempo is reintroduced.

    # Dashboards
    ./provision/dashboards/node-exporter.nix
    ./provision/dashboards/traefik-dashboard.nix
    ./provision/dashboards/mktxp.nix
  ];

  #networking.firewall.allowedTCPPorts = [ config.custom.world.services.grafana.port ]; # 3000 for Grafana

  services.grafana = {
    enable = true;

    # Not available yet, so done manually above
    # Should be available now
    openFirewall = true;

    dataDir = config.custom.world.services.grafana.dataDir;

    # ONLY AVAILABLE IN UNSTABLE :()
    #declarativePlugins = with pkgs.grafanaPlugins; [
    #  grafana-piechart-panel
    #  grafana-worldmap-panel
    #  grafana-clock-panel
    #  restoring drilldown functionality lost by using declarative plugins
    #  grafana-metricsdrilldown-app
    #  grafana-lokiexplore-app
    #  grafana-exploretraces-app
    #  grafana-pyroscope-app
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
        # NixOS 26.05 requires an explicit secret_key (no default). Provided via
        # sops file-provider; holds the old default so existing DB secrets stay
        # decryptable. See secrets_monitoring.nix.
        secret_key = "$__file{${config.sops.secrets."grafana/secret_key".path}}";
      };

      # Reverse Proxy settings
    };
  };

  # Traefik config to route traffic to Grafana (only when traefik is enabled on this host).
  services.traefik.dynamicConfigOptions = lib.mkIf config.services.traefik.enable {
    http.routers.grafana = {
      entryPoints = [
        "http"
        "https"
      ];
      rule = "Host(`${config.custom.world.services.grafana.domain}`)";
      service = "grafana";
      tls.domains = [ { main = "*.gideonwolfe.xyz"; } ];
      tls.certResolver = "myresolver";
    };

    http.services.grafana = {
      loadBalancer = {
        passHostHeader = true;
        servers = [ { url = "http://${config.custom.world.services.grafana.ip}:${toString config.custom.world.services.grafana.port}"; } ];
      };
    };
  };
}
