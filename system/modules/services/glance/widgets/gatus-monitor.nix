{ world }:
let
  service = world.services.gatus;
  baseURL = "${service.protocol}://${service.ip}:${toString service.port}";
in
{
  type = "custom-api";
  title = "Gatus";
  title-url = baseURL;
  cache = "1m";
  css-class = "gatus-monitor";
  options = {
    base-url = baseURL;
    style = "compact";
    duration = "24h";
    group = "";
    compact-metric = "uptime";
    show-failing-only = false;
    show-only-configured = false;

    calibre-web-automated = "sh:calibre-web";
    dawarich = "sh:dawarich";
    freshrss = "sh:freshrss";
    immich = "sh:immich";
    it-tools = "sh:it-tools";
    karakeep = "sh:karakeep";
    mealie = "sh:mealie";
    romm = "sh:romm";
    shelfmark = "mdi:bookshelf";
    scrutiny = "sh:scrutiny";
    bazarr = "sh:bazarr";
    jellyfin = "sh:jellyfin";
    navidrome = "sh:navidrome";
    netbox = "sh:netbox";
    nzbget = "sh:nzbget";
    prowlarr = "sh:prowlarr";
    radarr = "sh:radarr";
    seerr = "mdi:movie-search";
    slskd = "sh:slskd";
    sonarr = "sh:sonarr";
    soulsync-webui = "mdi:music-box-multiple";
    baikal = "sh:baikal";
    grafana = "sh:grafana";
    loki = "sh:loki";
    prometheus = "sh:prometheus";
    tempo = "mdi:chart-timeline";
    crowdsec = "sh:crowdsec";
    traefik = "sh:traefik";
  };
  template = builtins.readFile ./gatus-monitor.html;
}
