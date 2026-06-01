{ pkgs, lib, config, ... }:

# Shelfmark - self-hosted book search & request UI
#
# Upstream:        https://github.com/calibrain/shelfmark
# Container image: ghcr.io/calibrain/shelfmark:latest
# Default port:    8084 (http)
#
# Bind mount layout (host -> container):
#   /data/shelfmark/config                   -> /config        (app DB + artwork cache)
#   /data/calibre-web-automated/ingest       -> /books          (CWA auto-import target)
#
# We deliberately point /books at the CWA ingest directory so anything
# Shelfmark downloads is picked up by Calibre-Web-Automated and moved into the
# library. Per upstream guidance, this is the recommended pattern.
#
# LAN-only: no Traefik router, no public DNS. Reach it directly at
# http://<vm_app1>:8084.
let
  svc = config.custom.world.services.shelfmark;
  dataDir = "/data/shelfmark";
  # CWA's ingest folder (see calibre-web-automated/cwa.nix). Anything dropped
  # here is processed by CWA and then REMOVED, which is exactly what we want
  # for Shelfmark's download destination.
  cwaIngestDir = "/data/calibre-web-automated/ingest";
in
{
  virtualisation.oci-containers.containers.shelfmark = {
    image = "ghcr.io/calibrain/shelfmark:v1.3.0";
    autoStart = true;

    # Map the host port (from world.services) to the container's internal 8084.
    ports = [ "${builtins.toString svc.port}:8084" ];

    environment = {
      PUID = "1000";
      PGID = "100";

      TZ = "America/New_York";

      # `universal` is upstream's recommended search mode (metadata-provider
      # driven, aggregates across configured sources, full audiobook support).
      SEARCH_MODE = "universal";
    };

    # Optional secrets (Hardcover API key, OIDC client secret, etc.) can be
    # wired in here via sops the same way other apps on this VM do.
    # environmentFiles = [ config.sops.secrets."shelfmark/env".path ];

    volumes = [
      # Persistent config (SQLite DB, settings, artwork cache).
      "${dataDir}/config:/config"

      # Download destination -> CWA ingest folder for auto-import.
      "${cwaIngestDir}:/books"
    ];
  };

  # Make sure the local bind-mount targets exist with sensible ownership
  # before the container starts. Matches PUID=1000 / PGID=100 above.
  # The CWA ingest dir is created by cwa.nix, no need to redeclare it.
  systemd.tmpfiles.rules = [
    "d ${dataDir}         0755 1000 100 - -"
    "d ${dataDir}/config  0755 1000 100 - -"
  ];
}
