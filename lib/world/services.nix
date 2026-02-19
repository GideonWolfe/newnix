{ lib, config, ... }:
let
  mkService =
    { name
    , ip
    , port
    , domain ? ""
    , protocol ? "http"
    , extraOptions ? {}
    }:
    {
      ip = lib.mkOption {
        type = lib.types.str;
        default = ip;
        description = "IP for ${name} service";
      };

      protocol = lib.mkOption {
        type = lib.types.enum [ "http" "https" ];
        default = protocol;
        description = "Protocol for ${name} service";
      };

      domain = lib.mkOption {
        type = lib.types.str;
        default = domain;
        description = "Domain for ${name} service";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = port;
        description = "Port for ${name} service";
      };
    } // extraOptions;
in
{
  options.custom.world.services = {
    
    ####################
    # Monitoring Stack #
    ####################
    grafana = mkService {
      name = "Grafana";
      ip = config.custom.world.hosts.monitor.ip;
      port = 3000;
      domain = "cromulus.gideonwolfe.xyz";
      protocol = "https";
      extraOptions = {
        dataDir = lib.mkOption {
          type = lib.types.str;
          default = "/var/lib/grafana";
          description = "Data directory for Grafana";
        };
      };
    };
    prometheus = mkService {
      name = "Prometheus";
      ip = config.custom.world.hosts.monitor.ip;
      port = 9090;
      domain = "prom.gideonwolfe.xyz";
      protocol = "https";
    };
    loki = mkService {
      name = "Loki";
      ip = config.custom.world.hosts.monitor.ip;
      port = 3100;
      domain = "loki.gideonwolfe.xyz";
      protocol = "https";
    };
    tempo = mkService {
      name = "Tempo";
      ip = config.custom.world.hosts.monitor.ip;
      port = 3200;
      domain = "tempo.gideonwolfe.xyz";
      protocol = "http";
    };

    ###############
    # Media Stack #
    ###############
    sonarr = mkService {
      name = "Sonarr";
      ip = config.custom.world.hosts.media.ip;
      port = 8989;
      domain = "";
      protocol = "http";
    };
    radarr = mkService {
      name = "Radarr";
      ip = config.custom.world.hosts.media.ip;
      port = 7878;
      domain = "";
      protocol = "http";
    };
    prowlarr = mkService {
      name = "Prowlarr";
      ip = config.custom.world.hosts.media.ip;
      port = 9696;
      domain = "";
      protocol = "http";
    };
    recyclarr = mkService {
      name = "Recyclarr";
      ip = config.custom.world.hosts.media.ip;
      port = 4533;
      domain = "";
      protocol = "http";
    };
    nzbget = mkService {
      name = "NZBGet";
      ip = config.custom.world.hosts.media.ip;
      port = 6789;
      domain = "";
      protocol = "http";
    };
    jellyfin = mkService {
      name = "Jellyfin";
      ip = config.custom.world.hosts.media.ip;
      port = 8096;
      domain = "jellyfin.gideonwolfe.xyz";
      protocol = "https";
    };
    seerr = mkService {
      name = "Seerr";
      ip = config.custom.world.hosts.media.ip;
      port = 5055;
      domain = "jellyseerr.gideonwolfe.xyz";
      protocol = "https";
    };
    navidrome = mkService {
      name = "Navidrome";
      ip = config.custom.world.hosts.media.ip;
      port = 4533;
      domain = "nd.gideonwolfe.xyz";
      protocol = "https";
    };
    slskd = mkService {
      name = "SoulSeek Daemon";
      ip = config.custom.world.hosts.media.ip;
      port = 5030;
      domain = "";
      protocol = "http";
    };
    soulsync-webui = mkService {
      name = "SoulSync";
      ip = config.custom.world.hosts.media.ip;
      port = 8008;
      domain = "";
      protocol = "http";
    };
  };
}
