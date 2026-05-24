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

    ################
    # Home Network #
    ################
    traefik = mkService {
      name = "Traefik";
      ip = config.custom.world.hosts.proxmox.vms.vm_ingress.ip;
      port = 8080;
      domain = "";
      protocol = "http";
    };
    crowdsec = mkService {
      name = "CrowdSec";
      ip = config.custom.world.hosts.proxmox.vms.vm_ingress.ip;
      port = 4223;
      domain = "";
      protocol = "http";
    };

    ###############
    # Media Stack #
    ###############
    sonarr = mkService {
      name = "Sonarr";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 8989;
      domain = "";
      protocol = "http";
    };
    radarr = mkService {
      name = "Radarr";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 7878;
      domain = "";
      protocol = "http";
    };
    prowlarr = mkService {
      name = "Prowlarr";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 9696;
      domain = "";
      protocol = "http";
    };
    # NOTE: recyclarr is a CLI/cron tool with no web UI; no port is exposed.
    # The previous 4533 entry collided with navidrome. Kept here only so other
    # modules can still reference the service IP, with a sentinel port of 0.
    recyclarr = mkService {
      name = "Recyclarr";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 0;
      domain = "";
      protocol = "http";
    };
    nzbget = mkService {
      name = "NZBGet";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 6789;
      domain = "";
      protocol = "http";
    };
    jellyfin = mkService {
      name = "Jellyfin";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 8096;
      domain = "jellyfin.gideonwolfe.xyz";
      protocol = "https";
    };
    bazarr = mkService {
      name = "Bazarr";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 6767;
      protocol = "http";
    };
    seerr = mkService {
      name = "Seerr";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 5055;
      domain = "seerr.gideonwolfe.xyz";
      protocol = "https";
    };
    navidrome = mkService {
      name = "Navidrome";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 4533;
      domain = "nd.gideonwolfe.xyz";
      protocol = "https";
    };
    slskd = mkService {
      name = "SoulSeek Daemon";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 5030;
      domain = "";
      protocol = "http";
    };
    soulsync-webui = mkService {
      name = "SoulSync";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 8008;
      domain = "";
      protocol = "http";
    };
    
    # Other Apps
    netbox = mkService {
      name = "NetBox";
      ip = config.custom.world.hosts.proxmox.vms.vm_media.ip;
      port = 9001;
      domain = "";
      protocol = "http";
    };
    paperless = mkService {
      name = "Paperless-ngx";
      ip = config.custom.world.hosts.proxmox.vms.vm_app1.ip;
      port = 4232;
      domain = "";
      protocol = "http";
    };
    kiwix = mkService {
      name = "Kiwix";
      ip = config.custom.world.hosts.proxmox.vms.vm_app1.ip;
      port = 4302;
    };
    romm = mkService {
      name = "RomM";
      ip = config.custom.world.hosts.proxmox.vms.vm_app1.ip;
      domain = "retro86.gideonwolfe.xyz";
      port = 4240;
    };
    mealie = mkService {
      name = "Mealie";
      ip = config.custom.world.hosts.proxmox.vms.vm_app1.ip;
      domain = "mealie.gideonwolfe.xyz";
      port = 4217;
    };
    immich = mkService {
      name = "Immich";
      ip = config.custom.world.hosts.proxmox.vms.vm_app1.ip;
      # LAN-only for now (no Traefik router, no public DNS). Reach it directly
      # at http://<vm_app1>:2283 until we're ready to expose it to the WAN.
      domain = "";
      # 2283 is Immich's upstream default; we keep it so internal tooling
      # (e.g. the CLI, mobile apps used over LAN) sees the expected port.
      port = 2283;
      protocol = "http";
    };
    calibre-web-automated = mkService {
      name = "Calibre-Web-Automated";
      ip = config.custom.world.hosts.proxmox.vms.vm_app1.ip;
      domain = "";
      port = 8083;
      protocol = "http";
    };
    pinchflat = mkService {
      name = "Pinchflat";
      ip = config.custom.world.hosts.proxmox.vms.vm_app1.ip;
      port = 8945;
      domain = "";
      protocol = "http";
    };
    dawarich = mkService {
      name = "Dawarich";
      ip = config.custom.world.hosts.proxmox.vms.vm_app1.ip;
      port = 4268;
      domain = "";
      protocol = "http";
    };
    scrutiny = mkService {
      name = "Scrutiny";
      ip = config.custom.world.hosts.mnemosyne.ip;
      port = 5232;
      domain = "";
      protocol = "http";
    };
  };
}
