{ config, lib, ... }:
let
  svc = config.custom.world.services;
  hosts = config.custom.world.hosts;
  pve = hosts.proxmox.nodes;
in
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = true;
    allowedHosts = "*";

    settings = {
      title = "Dashboard";
      theme = "light";
      #color = "slate";
      headerStyle = "clean";
      layout = {
        # Monitoring = {
        #   style = "row";
        #   columns = 4;
        #   icon = "mdi-chart-line";
        # };
        Media = {
          style = "row";
          columns = 4;
          icon = "mdi-filmstrip";
        };
        "Media Management" = {
          style = "row";
          columns = 4;
          icon = "mdi-download";
        };
        Music = {
          style = "row";
          columns = 3;
          icon = "mdi-music";
        };
        Infrastructure = {
          style = "row";
          columns = 5;
          icon = "mdi-server";
        };
        Applications = {
          style = "row";
          columns = 3;
          icon = "mdi-apps";
        };
      };
    };

    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
      {
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];

    bookmarks = [
      {
        Development = [
          {
            GitHub = [
              {
                abbr = "GH";
                href = "https://github.com/";
              }
            ];
          }
          {
            NixOS-Search = [
              {
                abbr = "NX";
                href = "https://search.nixos.org/";
              }
            ];
          }
        ];
      }
      {
        Social = [
          {
            Reddit = [
              {
                abbr = "RD";
                href = "https://reddit.com/";
              }
            ];
          }
          {
            YouTube = [
              {
                abbr = "YT";
                href = "https://youtube.com/";
              }
            ];
          }
        ];
      }
    ];

    services = [
      #################
      # Monitoring    #
      #################
        {
          Monitoring = [
            { Traefik = {
                href = "${svc.traefik.protocol}://${svc.traefik.ip}:${builtins.toString svc.traefik.port}";
                description = "Traefik";
            }; }
            { Crowdsec = {
                href = "https://app.crowdsec.net";
                description = "CrowdSec Console";
            }; }
            # { Grafana = {
            #     href = "${svc.grafana.protocol}://${svc.grafana.domain}";
            #     description = "Grafana";
            # }; }
            # { Prometheus = {
            #     href = "${svc.prometheus.protocol}://${svc.prometheus.domain}";
            #     description = "Prometheus";
            # }; }
            # { Loki = {
            #     href = "${svc.loki.protocol}://${svc.loki.domain}";
            #     description = "Loki";
            # }; }
            # { Tempo = {
            #     href = "${svc.tempo.protocol}://${svc.tempo.ip}:${builtins.toString svc.tempo.port}";
            #     description = "Tempo";
            # }; }
          ];
        }

      #################
      # Media         #
      #################
      {
        Media = [
          {
            Jellyfin = {
              href = "http://${svc.jellyfin.ip}:${builtins.toString svc.jellyfin.port}";
              description = "Media Server";
            };
          }
          {
            Seerr = {
              href = "http://${svc.seerr.ip}:${builtins.toString svc.seerr.port}";
              description = "Media Requests";
            };
          }
        ];
      }

      #################
      # Media Mgmt    #
      #################
      {
        "Media Management" = [
          {
            Sonarr = {
              href = "${svc.sonarr.protocol}://${svc.sonarr.ip}:${builtins.toString svc.sonarr.port}";
              description = "Movie Library";
            };
          }
          {
            Radarr = {
              href = "${svc.radarr.protocol}://${svc.radarr.ip}:${builtins.toString svc.radarr.port}";
              description = "TV Library";
            };
          }
          {
            Prowlarr = {
              href = "${svc.prowlarr.protocol}://${svc.prowlarr.ip}:${builtins.toString svc.prowlarr.port}";
              description = "Indexers";
            };
          }
          {
            Bazarr = {
              href = "${svc.bazarr.protocol}://${svc.bazarr.ip}:${builtins.toString svc.bazarr.port}";
              description = "Subtitles";
            };
          }
          {
            NZBGet = {
              href = "${svc.nzbget.protocol}://${svc.nzbget.ip}:${builtins.toString svc.nzbget.port}";
              description = "NZB Downloader";
            };
          }
        ];
      }

      #################
      # Music         #
      #################
      {
        Music = [
          {
            Navidrome = {
              href = "http://${svc.navidrome.ip}:${builtins.toString svc.navidrome.port}";
              description = "Music Server";
            };
          }
          {
            Slskd = {
              href = "${svc.slskd.protocol}://${svc.slskd.ip}:${builtins.toString svc.slskd.port}";
              description = "SoulSeek Daemon";
            };
          }
          {
            SoulSync = {
              href = "${svc.soulsync-webui.protocol}://${svc.soulsync-webui.ip}:${builtins.toString svc.soulsync-webui.port}";
              description = "Music Library Manager";
            };
          }
        ];
      }

      #################
      # Infrastructure#
      #################
      {
        Infrastructure = [
          {
            "PVE Node Net" = {
              href = "https://${pve.pvenet.ip}:8006";
              description = "pvenet";
            };
          }
          {
            "PVE Node 1" = {
              href = "https://${pve.pve1.ip}:8006";
              description = "pve1";
            };
          }
          {
            "PVE Node 2" = {
              href = "https://${pve.pve2.ip}:8006";
              description = "pve2";
            };
          }
          {
            "PVE Node 3" = {
              href = "https://${pve.pve3.ip}:8006";
              description = "pve3";
            };
          }
          {
            "Router" = {
              href = "http://${hosts.router.ip}";
              description = "Router Dashboard";
            };
          }
        ];
      }

      #################
      # Applications  #
      #################
        {
          Applications = [
            # { NetBox = {
            #     href = "${svc.netbox.protocol}://${svc.netbox.ip}:${builtins.toString svc.netbox.port}";
            #     description = "NetBox";
            # }; }
            # { Paperless = {
            #     href = "${svc.paperless.protocol}://${svc.paperless.ip}:${builtins.toString svc.paperless.port}";
            #     description = "Paperless-ngx";
            # }; }
            { Romm = {
                href = "${svc.romm.protocol}://${svc.romm.ip}:${builtins.toString svc.romm.port}";
                description = "Emulation Library";
            }; }
          ];
        }
    ];
  };
}
