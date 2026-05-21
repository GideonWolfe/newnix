{ pkgs, lib, config, ... }:

# Calibre-Web-Automated (CWA)
#
# Nix translation of the upstream docker-compose template:
#   https://github.com/crocodilestick/Calibre-Web-Automated#using-docker-compose-recommended
#
# Container image: crocodilestick/calibre-web-automated:latest
#
# Bind mount layout (host -> container):
#   /data/calibre-web-automated/config           -> /config
#   /data/calibre-web-automated/ingest           -> /cwa-book-ingest        (files DELETED after processing!)
#   /data/calibre-web-automated/library          -> /calibre-library
#   /data/calibre-web-automated/calibre-plugins  -> /config/.config/calibre/plugins
#
# All three primary directories MUST be separate (no nested binds).
let
  svc = config.custom.world.services.calibre-web-automated;
  dataDir = "/data/calibre-web-automated";
in
{
  virtualisation.oci-containers.containers.calibre-web-automated = {
    image = "crocodilestick/calibre-web-automated:v4.0.6";
    autoStart = true;

    # Map the host port (from world.services) to the container's internal 8083.
    # Change CWA_PORT_OVERRIDE below if you also change the container-side port.
    ports = [ "${builtins.toString svc.port}:8083" ];

    environment = {

      PUID = "1000";
      PGID = "100";

      TZ = "America/New_York";

      # If your library is on a network share (NFS/SMB), set this to "true"
      # to disable SQLite WAL and use polling-based file watchers.
      NETWORK_SHARE_MODE = "true";
    };

    # Provide secrets (e.g. HARDCOVER_TOKEN) via an env file managed by sops.
    # Uncomment once the secret is defined under ./secrets/.
    # environmentFiles = [ config.sops.secrets."calibre-web-automated/env".path ];

    volumes = [
      # Persistent CWA config (app.db, logs, processed_books, etc.).
      # CW users migrating: stop your CW instance and copy its /config here.
      "${dataDir}/config:/config"

      # Ingest folder. ANYTHING placed here is processed and then REMOVED.
      # Do not download directly into this folder; copy completed files in.
      "${dataDir}/ingest:/cwa-book-ingest"

      # Calibre library (contains metadata.db). If empty, CWA will create one.
      #"${dataDir}/library:/calibre-library"
      "/nas/tank/media/books:/calibre-library"

      # Optional: existing Calibre plugin directory.
      # Also copy customize.py.json into ${dataDir}/config/.config/calibre/.
      "${dataDir}/calibre-plugins:/config/.config/calibre/plugins"
    ];

  };

  # Make sure the bind-mount targets exist with sensible ownership before the
  # container starts. Matches PUID=1000 / PGID=100 above.
  systemd.tmpfiles.rules = [
    "d ${dataDir}                          0755 1000 100 - -"
    "d ${dataDir}/config                   0755 1000 100 - -"
    "d ${dataDir}/ingest                   0755 1000 100 - -"
    "d ${dataDir}/calibre-plugins          0755 1000 100 - -"
  ];
}
