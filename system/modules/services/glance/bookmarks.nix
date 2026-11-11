{ world }:
let
  serviceLink = name: title: icon:
    let
      service = world.services.${name};
    in
    {
      inherit title icon;
      # The backend ports serve HTTP; TLS terminates at Traefik, not these IPs.
      url = "http://${service.ip}:${toString service.port}";
    };
  grafanaLink = title: path:
    (serviceLink "grafana" title "sh:grafana") // {
      url = "${(serviceLink "grafana" title "sh:grafana").url}${path}";
    };
  nodeLink = name: title: {
    inherit title;
    url = "https://${world.hosts.proxmox.nodes.${name}.ip}:8006";
    icon = "sh:proxmox";
  };
in
{
  web = {
    type = "bookmarks";
    title = "Web";
    groups = [
      {
        title = "Everyday";
        links = [
          { title = "YouTube"; url = "https://youtube.com/"; icon = "si:youtube"; }
          { title = "Reddit"; url = "https://reddit.com/"; icon = "si:reddit"; }
        ];
      }
      {
        title = "Development";
        links = [
          { title = "GitHub"; url = "https://github.com/"; icon = "si:github"; }
          (serviceLink "forgejo" "Forgejo" "sh:forgejo")
          { title = "NixOS Search"; url = "https://search.nixos.org/"; icon = "si:nixos"; }
        ];
      }
    ];
  };

  applications = {
    type = "bookmarks";
    title = "Applications";
    groups = [
      {
        title = "Personal";
        links = [
          (serviceLink "paperless" "Paperless" "sh:paperless-ngx")
          (serviceLink "karakeep" "Karakeep" "sh:karakeep")
          (serviceLink "mealie" "Mealie" "sh:mealie")
          (serviceLink "immich" "Immich" "sh:immich")
          (serviceLink "dawarich" "Dawarich" "sh:dawarich")
          (serviceLink "home-assistant" "Home Assistant" "sh:home-assistant")
          (serviceLink "tududi" "Tududi" "sh:tududi")
        ];
      }
      {
        title = "Make";
        links = [
          (serviceLink "printventory" "Printventory" "mdi:printer-3d")
          { title = "Mainsail"; url = "http://192.168.88.176"; icon = "sh:mainsail"; }
        ];
      }
      {
        title = "Acquire";
        links = [
          (serviceLink "seerr" "Seerr" "sh:seerr")
          (serviceLink "youtarr" "Youtarr" "sh:youtarr.png")
          (serviceLink "shelfmark" "Shelfmark" "sh:shelfmark")
          (serviceLink "soulsync-webui" "SoulSync" "sh:soulsync.png")
          (serviceLink "dispatcharr" "Dispatcharr" "sh:dispatcharr")
        ];
      }
      {
        title = "Tools";
        links = [
          (serviceLink "it-tools" "IT Tools" "sh:it-tools")
          (serviceLink "freshrss" "FreshRSS" "sh:freshrss")
          (serviceLink "copyparty" "Copyparty" "sh:copyparty")
          (serviceLink "open-webui" "Open WebUI" "sh:open-webui")
        ];
      }
      {
        title = "Watch & listen";
        links = [
          (serviceLink "jellyfin" "Jellyfin" "sh:jellyfin")
          (serviceLink "navidrome" "Navidrome" "sh:navidrome")
          (serviceLink "romm" "RomM" "sh:romm")
          (serviceLink "calibre-web-automated" "Calibre" "sh:calibre-web")
        ];
      }
      {
        title = "Play";
        links = [
          { title = "Golf"; url = "https://kindahardgolf.com"; icon = "mdi:golf"; }
          { title = "OpenGuessr"; url = "https://openguessr.com"; icon = "mdi:map-marker-question-outline"; }
          { title = "Globle"; url = "https://globle-game.com/game"; icon = "mdi:map-marker-question-outline"; }
          { title = "Semantle"; url = "https://semantle.com"; icon = "mdi:chat-question-outline"; }
          { title = "Redactle"; url = "https://www.redactle.net"; icon = "sh:wikipedia"; }
          { title = "Anthropeum"; url = "https://www.anthropeum.com"; icon = "mdi:calendar-question-outline"; }
        ];
      }
    ];
  };

  infrastructure = {
    type = "bookmarks";
    title = "Infrastructure";
    groups = [
      {
        title = "Monitoring";
        links = [
          (serviceLink "gatus" "Gatus" "sh:gatus")
          (serviceLink "grafana" "Grafana" "sh:grafana")
          (grafanaLink "NAS Dashboard" "/d/agzdgq4/mnemosyne-zfs-pool-staging")
          (grafanaLink "Backup NAS Dashboard" "/d/agdzndc/soteria-tank-zfs-pool-staging")
          (serviceLink "scrutiny" "Scrutiny" "sh:scrutiny")
        ];
      }
      {
        title = "Manage";
        links = [
          (serviceLink "traefik" "Traefik" "sh:traefik")
          {
            title = "Router";
            url = "http://${world.hosts.router.ip}";
            icon = "sh:mikrotik";
          }
          (nodeLink "pvenet" "Proxmox")
        ];
      }
      {
        title = "Nodes";
        links = [
          (nodeLink "pve1" "PVE 1")
          (nodeLink "pve2" "PVE 2")
          (nodeLink "pve3" "PVE 3")
        ];
      }
    ];
  };
}