{ config, lib, ... }:
let
  svc = config.custom.world.services;
  hosts = config.custom.world.hosts;
  pve = hosts.proxmox.nodes;
  # Pull base16 palette from stylix (no `#` prefix, suitable for CSS rgb()/hex)
  c = config.lib.stylix.colors.withHashtag;
in
{
  imports = [
    # Defines sops secrets + a `homepage-env` template that becomes our
    # EnvironmentFile, exposing HOMEPAGE_VAR_* to widgets below.
    ./secrets/secrets_homepage.nix
  ];

  services.homepage-dashboard = {
    enable = true;
    listenPort = 8082;
    openFirewall = true;
    allowedHosts = "*";

    # Inject decrypted secrets (HOMEPAGE_VAR_*) into the dashboard's
    # process environment. Referenced from services/widgets as
    # `{{HOMEPAGE_VAR_NAME}}` -- see ./secrets/secrets_homepage.nix.
    environmentFiles = [ config.sops.templates."homepage-env".path ];

    # Override Homepage's Tailwind theme CSS variables with stylix base16
    # colors. Homepage's `color` / `theme` settings only accept a fixed list
    # of names, so we drop straight into the CSS variables it uses.
    # customCSS = ''
    #   :root,
    #   html.dark,
    #   html.light,
    #   html.dark body,
    #   html.light body {
    #     /* Backgrounds */
    #     --bg-color: ${c.base00};
    #     --bg-color-secondary: ${c.base01};

    #     /* Text */
    #     --text-color: ${c.base05};
    #     --text-color-secondary: ${c.base04};

    #     /* Tailwind "theme" palette used by Homepage cards/widgets.
    #        Homepage references shades 50/100/200/...900 of its theme
    #        color. We map them to the base16 ramp so cards, hover states
    #        and borders all follow the stylix theme. */
    #     --color-theme-50:  ${c.base07};
    #     --color-theme-100: ${c.base06};
    #     --color-theme-200: ${c.base05};
    #     --color-theme-300: ${c.base04};
    #     --color-theme-400: ${c.base03};
    #     --color-theme-500: ${c.base02};
    #     --color-theme-600: ${c.base01};
    #     --color-theme-700: ${c.base01};
    #     --color-theme-800: ${c.base00};
    #     --color-theme-900: ${c.base00};
    #   }

    #   body, .dark body {
    #     background-color: ${c.base00} !important;
    #     color: ${c.base05} !important;
    #   }

    #   /* Service / bookmark cards */
    #   #information-widgets,
    #   .services-group .service-card,
    #   .bookmark-text,
    #   .bookmark {
    #     background-color: ${c.base01} !important;
    #     color: ${c.base05} !important;
    #   }

    #   /* Accents (links, icons, group headings) */
    #   a, .service-name, h1, h2, h3,
    #   .services-group > h2,
    #   .bookmarks-group > h2 {
    #     color: ${c.base0D} !important;
    #   }

    #   /* Hover / active accents */
    #   a:hover,
    #   .service-card:hover,
    #   .bookmark:hover {
    #     color: ${c.base0E} !important;
    #     border-color: ${c.base0D} !important;
    #   }
    # '';

    settings = {
      title = "Dashboard";
      theme = "light";
      #color = "neutral";
      headerStyle = "clean";
      useEqualHeights = true;
      layout = {
        Monitoring = {
          style = "row";
          columns = 4;
          icon = "mdi-chart-line";
        };
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
        Networking = {
          style = "column";
          columns = 2;
          icon = "mdi-router-wireless";
        };
        Infrastructure = {
          style = "column";
          columns = 2;
          icon = "mdi-server";
        };
        Applications = {
          style = "row";
          columns = 3;
          icon = "mdi-apps";
        };
        VMs = {
          style = "column";
          columns = 1;
          icon = "mdi-server-network";
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
            { Grafana = {
                href = "${svc.grafana.protocol}://${svc.grafana.ip}:${builtins.toString svc.grafana.port}";
                description = "Dashboard";
                icon = "grafana";
                widget = {
                  type = "grafana";
                  url = "${svc.grafana.protocol}://${svc.grafana.ip}:${builtins.toString svc.grafana.port}";
                  version = 2;
                  # When adding alerts: can have "totalalerts" and "alertstriggered"
                  fields = [ "dashboards" "datasources" ];
                  username = "{{HOMEPAGE_VAR_GRAFANA_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_GRAFANA_PASSWORD}}";
                };
            }; }
            { Prometheus = {
                href = "${svc.prometheus.protocol}://${svc.prometheus.ip}:${builtins.toString svc.prometheus.port}";
                description = "Metrics";
                icon = "prometheus";
                widget = {
                  type = "prometheus";
                  url = "${svc.prometheus.protocol}://${svc.prometheus.ip}:${builtins.toString svc.prometheus.port}";
                  # Basic auth via the generic proxy handler (behind reverse proxy)
                  username = "{{HOMEPAGE_VAR_PROMETHEUS_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_PROMETHEUS_PASSWORD}}";
                };
            }; }
            { Loki = {
                href = "${svc.loki.protocol}://${svc.loki.ip}:${builtins.toString svc.loki.port}";
                description = "Logs";
                icon = "loki";
            }; }
            { Tempo = {
                href = "${svc.tempo.protocol}://${svc.tempo.ip}:${builtins.toString svc.tempo.port}";
                description = "Traces";
                icon = "tempo";
            }; }
            { Gatus = {
                href = "${svc.gatus.protocol}://${svc.gatus.ip}:${builtins.toString svc.gatus.port}";
                description = "Uptime Dashboard";
                icon = "gatus";
                widget = {
                  type = "gatus";
                  url = "${svc.gatus.protocol}://${svc.gatus.ip}:${builtins.toString svc.gatus.port}";
                };
            }; }
          ];
        }
        {
          Networking = [
            { Traefik = {
                href = "${svc.traefik.protocol}://${svc.traefik.ip}:${builtins.toString svc.traefik.port}";
                description = "Dashboard";
                icon = "traefik-proxy";
                widget = {
                  type = "traefik";
                  url = "${svc.traefik.protocol}://${svc.traefik.ip}:${builtins.toString svc.traefik.port}";
                  fields = [ "routers" "services" "middleware" ];
                };
            }; }
            { Crowdsec = {
                href = "https://app.crowdsec.net";
                icon = "crowdsec";
                description = "Console";
            }; }
            {
              "Router" = {
                href = "http://${hosts.router.ip}";
                description = "Router Dashboard";
                icon = "mikrotik";
                widget = {
                  type = "mikrotik";
                  url = "http://${config.custom.world.hosts.router.ip}";
                  username = "{{HOMEPAGE_VAR_MIKROTIK_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_MIKROTIK_PASSWORD}}";
                  fields = [ "uptime" "cpuLoad" "memoryUsed" "numberOfLeases" ];
                };
              };
            }
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
              icon = "jellyfin";
              widget = {
                type = "jellyfin";
                url = "http://${svc.jellyfin.ip}:${builtins.toString svc.jellyfin.port}";
                fields = [ "movies" "series" "episodes" "songs" ];
                version = 1;
                key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
              };
            };
          }
          {
            Calibre = {
              href = "http://${svc.calibre-web-automated.ip}:${builtins.toString svc.calibre-web-automated.port}";
              description = "Ebook Library";
              icon = "calibre-web";
              # https://gethomepage.dev/widgets/services/calibre-web/
              widget = {
                type = "calibreweb";
                url = "http://${svc.calibre-web-automated.ip}:${builtins.toString svc.calibre-web-automated.port}";
                username = "{{HOMEPAGE_VAR_CALIBRE_USERNAME}}";
                password = "{{HOMEPAGE_VAR_CALIBRE_PASSWORD}}";
                fields = [ "books" "authors" "categories" "series" ];
              };
            };
          }
          {
            Shelfmark = {
              href = "http://${svc.shelfmark.ip}:${builtins.toString svc.shelfmark.port}";
              description = "Ebook Downloader";
              icon = "shelfmark";
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
              icon = "sonarr";
              widget = {
                type = "sonarr";
                url = "${svc.sonarr.protocol}://${svc.sonarr.ip}:${builtins.toString svc.sonarr.port}";
                key = "{{HOMEPAGE_VAR_SONARR_APIKEY}}";
                fields = [ "wanted" "queued" "series" ];
              };
            };
          }
          {
            Radarr = {
              href = "${svc.radarr.protocol}://${svc.radarr.ip}:${builtins.toString svc.radarr.port}";
              description = "TV Library";
              icon = "radarr";
              widget = {
                type = "radarr";
                url = "${svc.radarr.protocol}://${svc.radarr.ip}:${builtins.toString svc.radarr.port}";
                key = "{{HOMEPAGE_VAR_RADARR_APIKEY}}";
                fields = [ "wanted" "missing" "queued" "movies" ];
              };
            };
          }
          {
            Prowlarr = {
              href = "${svc.prowlarr.protocol}://${svc.prowlarr.ip}:${builtins.toString svc.prowlarr.port}";
              description = "Indexers";
              icon = "prowlarr";
              widget = {
                type = "prowlarr";
                url = "${svc.prowlarr.protocol}://${svc.prowlarr.ip}:${builtins.toString svc.prowlarr.port}";
                key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
                fields = [ "numberOfGrabs" "numberOfQueries" "numberofFailGrabs" ];
              };
            };
          }
          {
            Bazarr = {
              href = "${svc.bazarr.protocol}://${svc.bazarr.ip}:${builtins.toString svc.bazarr.port}";
              description = "Subtitles";
              icon = "bazarr";
              widget = {
                type = "bazarr";
                url = "${svc.bazarr.protocol}://${svc.bazarr.ip}:${builtins.toString svc.bazarr.port}";
                key = "{{HOMEPAGE_VAR_BAZARR_API_KEY}}";
                fields = [ "missingEpisodes" "missingMovies"];
              };
            };
          }
          {
            NZBGet = {
              href = "${svc.nzbget.protocol}://${svc.nzbget.ip}:${builtins.toString svc.nzbget.port}";
              description = "NZB Downloader";
              icon = "nzbget";
              widget = {
                type = "nzbget";
                url = "http://${svc.nzbget.ip}:${builtins.toString svc.nzbget.port}";
                username = "{{HOMEPAGE_VAR_NZBGET_USERNAME}}";
                password = "{{HOMEPAGE_VAR_NZBGET_PASSWORD}}";
                fields = [ "rate" "remaining" "downloaded" ];
              };
            };
          }
          {
            Seerr = {
              href = "http://${svc.seerr.ip}:${builtins.toString svc.seerr.port}";
              description = "Media Requests";
              icon = "seerr";
              widget = {
                # `seerr` is the new unified type (Jellyseerr+Overseerr merged);
                # only present in recent Homepage builds. Use the legacy alias
                # that matches the upstream we point at until nixpkgs catches up.
                type = "jellyseerr";
                url = "http://${svc.seerr.ip}:${builtins.toString svc.seerr.port}";
                key = "{{HOMEPAGE_VAR_SEERR_API_KEY}}";
                fields = [ "pending" "approved" "available" ];
              };
            };
          }
          # {
          #   Pinchflat = {
          #     icon = "pinchflat";
          #     href = "${svc.pinchflat.protocol}://${svc.pinchflat.ip}:${builtins.toString svc.pinchflat.port}";
          #     description = "YouTube Archiver";
          #   };
          # }
          # {
          #   TubeArchivist = {
          #     href = "${svc.tubearchivist.protocol}://${svc.tubearchivist.ip}:${builtins.toString svc.tubearchivist.port}";
          #     description = "YouTube Archive + Search";
          #     icon = "tube-archivist";
          #   };
          # }
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
              icon = "navidrome";
              widget = {
                type = "navidrome";
                url = "http://${svc.navidrome.ip}:${builtins.toString svc.navidrome.port}";
                user = "Gideon";
                token = "{{HOMEPAGE_VAR_NAVIDROME_TOKEN}}";
                salt = "{{HOMEPAGE_VAR_NAVIDROME_SALT}}";
              };
            };
          }
          {
            Slskd = {
              href = "${svc.slskd.protocol}://${svc.slskd.ip}:${builtins.toString svc.slskd.port}";
              description = "SoulSeek Daemon";
              icon = "slskd";
            };
          }
          {
            SoulSync = {
              href = "${svc.soulsync-webui.protocol}://${svc.soulsync-webui.ip}:${builtins.toString svc.soulsync-webui.port}";
              description = "Music Library Manager";
              icon = "soulsync.webp";
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
              icon = "proxmox";
            };
          }
          {
            "PVE Node 1" = {
              href = "https://${pve.pve1.ip}:8006";
              description = "pve1";
              icon = "proxmox";
            };
          }
          {
            "PVE Node 2" = {
              href = "https://${pve.pve2.ip}:8006";
              description = "pve2";
              icon = "proxmox";
            };
          }
          {
            "PVE Node 3" = {
              href = "https://${pve.pve3.ip}:8006";
              description = "pve3";
              icon = "proxmox";
            };
          }
          {
            "Scrutiny" = {
              href = "${svc.scrutiny.protocol}://${svc.scrutiny.ip}:${builtins.toString svc.scrutiny.port}";
              description = "Disk Health (mnemosyne)";
              icon = "scrutiny";
              widget = {
                type = "scrutiny";
                url = "http://${svc.scrutiny.ip}:${builtins.toString svc.scrutiny.port}";
                fields = [ "passed" "failed" "unknown" ];
              };
            };
          }
          {
            "Home Assistant" = {
              href = "http://192.168.88.177:8123";
              description = "Home Automation";
              icon = "home-assistant";
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
            { "IT Tools" = {
                href = "${svc.it-tools.protocol}://${svc.it-tools.ip}:${builtins.toString svc.it-tools.port}";
                description = "Developer Utilities";
                icon = "it-tools";
            }; }
            { FreshRSS = {
                href = "${svc.freshrss.protocol}://${svc.freshrss.ip}:${builtins.toString svc.freshrss.port}";
                description = "RSS Reader";
                icon = "freshrss";
                widget = {
                  type = "freshrss";
                  url = "${svc.freshrss.protocol}://${svc.freshrss.ip}:${builtins.toString svc.freshrss.port}";
                  username = "{{HOMEPAGE_VAR_FRESHRSS_USERNAME}}"; # Set in secrets_homepage.yaml + homepage-env template
                  password = "{{HOMEPAGE_VAR_FRESHRSS_API_KEY}}"; # Set in secrets_homepage.yaml + homepage-env template
                  fields = [ "subscriptions" "unread" ];
                };
            }; }
            { Romm = {
                href = "${svc.romm.protocol}://${svc.romm.ip}:${builtins.toString svc.romm.port}";
                description = "Emulation Library";
                icon = "romm";
                widget = {
                  type = "romm";
                  url = "${svc.romm.protocol}://${svc.romm.ip}:${builtins.toString svc.romm.port}";
                  fields = [ "platforms" "totalRoms" "saves" "totalfilesize" ];
                };

            }; }
            { Mealie = {
                href = "http://${svc.mealie.ip}:${builtins.toString svc.mealie.port}";
                description = "Recipe Manager";
                icon = "mealie";
                widget = {
                  type = "mealie";
                  url = "http://${svc.mealie.ip}:${builtins.toString svc.mealie.port}";
                  key = "{{HOMEPAGE_VAR_MEALIE_API_KEY}}"; # Set in secrets_homepage.yaml + homepage-env template
                  version = 2;
                  fields = [ "recipes" "users" "categories" "tags" ];
                };

            }; }
            { Immich = {
                href = "${svc.immich.protocol}://${svc.immich.ip}:${builtins.toString svc.immich.port}";
                description = "Photo Library";
                icon = "immich";
                widget = {
                  type = "immich";
                  url = "http://${svc.immich.ip}:${builtins.toString svc.immich.port}";
                  key = "{{HOMEPAGE_VAR_IMMICH_API_KEY}}"; # Set in secrets_homepage.yaml + homepage-env template
                  version = 2;
                  fields = [ "photos" "videos" ];
                };

            }; }
            { Dawarich = {
                href = "${svc.dawarich.protocol}://${svc.dawarich.ip}:${builtins.toString svc.dawarich.port}";
                description = "Location History";
                icon = "dawarich";
            }; }
            { Karakeep = {
                href = "${svc.karakeep.protocol}://${svc.karakeep.ip}:${builtins.toString svc.karakeep.port}";
                description = "Bookmarks";
                icon = "karakeep";
                widget = {
                  type = "karakeep";
                  url = "http://${svc.karakeep.ip}:${builtins.toString svc.karakeep.port}";
                  key = "{{HOMEPAGE_VAR_KARAKEEP_API_KEY}}";
                  fields = [ "lists" "bookmarks" "tags" "archived" ];
                };
            }; }
          ];
        }

      #################
      # VMs           #
      #################
        {
          VMs = [
            { "vm-ingress" = {
                href = "ssh://vm-ingress";
                description = "Ingress / Traefik";
                icon = "mdi-monitor";
            }; }
            { "vm-app1" = {
                href = "ssh://vm-app1";
                description = "Applications";
                icon = "mdi-monitor";
            }; }
            { "vm-app2" = {
                href = "ssh://vm-app2";
                description = "Applications";
                icon = "mdi-monitor";
            }; }
            { "vm-media" = {
                href = "ssh://vm-media";
                description = "Media Stack";
                icon = "mdi-monitor";
            }; }
            { "vm-test" = {
                href = "ssh://vm-test";
                description = "Test / Scratch";
                icon = "mdi-monitor";
            }; }
          ];
        }
    ];
  };

  # `services.homepage-dashboard.environmentFile` is read only at unit
  # start, so changes to the sops template (e.g. a new HOMEPAGE_VAR_*) do
  # NOT take effect on a normal `nixos-rebuild switch` -- the unit keeps
  # running with the old env. Hash the template content into restartTriggers
  # so activation force-restarts homepage-dashboard whenever the env file
  # would change.
  systemd.services.homepage-dashboard.restartTriggers = [
    config.sops.templates."homepage-env".content
  ];
}
