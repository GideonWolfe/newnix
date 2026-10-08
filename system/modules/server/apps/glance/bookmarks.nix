{ world }:
let
  serviceLink = name: title: icon:
    let
      service = world.services.${name};
    in
    {
      inherit title icon;
      # Registered domains use Traefik's TLS endpoint; LAN-only services stay direct.
      url = if service.domain != "" then
        "https://${service.domain}"
      else
        "${service.protocol}://${service.ip}:${toString service.port}";
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
          (serviceLink "printventory" "Printventory" "mdi:printer-3d")
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
    ];
  };

  media = {
    type = "bookmarks";
    title = "Media";
    groups = [
      {
        title = "Watch & listen";
        links = [
          (serviceLink "jellyfin" "Jellyfin" "sh:jellyfin")
          (serviceLink "navidrome" "Navidrome" "sh:navidrome")
          (serviceLink "seerr" "Seerr" "mdi:movie-search")
          (serviceLink "youtarr" "Youtarr" "si:youtube")
        ];
      }
      {
        title = "Read & play";
        links = [
          (serviceLink "calibre-web-automated" "Calibre" "sh:calibre-web")
          (serviceLink "shelfmark" "Shelfmark" "mdi:bookshelf")
          (serviceLink "romm" "RomM" "sh:romm")
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
          (serviceLink "scrutiny" "Scrutiny" "sh:scrutiny")
          (serviceLink+"/d/agdzndc/soteria-tank-zfs-pool-staging" "soteria" "Soteria" "sh:grafana")
        ];
      }
      {
        title = "Manage";
        links = [
          (serviceLink "traefik" "Traefik" "sh:traefik")
          {
            title = "Router";
            url = "http://${world.hosts.router.ip}";
            icon = "mdi:router-network";
          }
          {
            title = "Proxmox";
            url = "https://${world.hosts.proxmox.nodes.pvenet.ip}:8006";
            icon = "sh:proxmox";
          }
        ];
      }
    ];
  };
}