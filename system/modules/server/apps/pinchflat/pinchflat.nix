{ pkgs, lib, config, ... }:

# Pinchflat - self-hosted YouTube media manager / archiver built on yt-dlp
#
# Upstream:        https://github.com/kieraneglin/pinchflat
# Container image: ghcr.io/kieraneglin/pinchflat (also keglin/pinchflat on Docker Hub)
# Default port:    8945 (http)
#
# Bind mount layout (host -> container):
#   /data/pinchflat/config        -> /config       (SQLite DB, app state, logs)
#   /nas/tank/media/youtube       -> /downloads    (downloaded media on the NAS)
#
# IMPORTANT (upstream guidance):
#   * Do NOT run the container as root - we use PUID=1000 / PGID=100 below.
#   * SQLite + WAL does not play well with network shares. The /config dir lives
#     on the VM's local data disk for that reason; only /downloads is on NFS.
let
  svc = config.custom.world.services.pinchflat;
  dataDir = "/data/pinchflat";
  # Where downloaded YouTube content lands on the NAS (NFS-mounted via mnemosyne-nfs).
  downloadsDir = "/nas/tank/media/youtube";
in
{
  virtualisation.oci-containers.containers.pinchflat = {
    image = "ghcr.io/kieraneglin/pinchflat:v2025.6.6";
    autoStart = true;

    # Map the host port (from world.services) to the container's internal 8945.
    ports = [ "${builtins.toString svc.port}:8945" ];

    environment = {
      # File ownership for downloaded media / config.
      PUID = "1000";
      PGID = "100";

      TZ = "America/New_York";

      # debug is upstream's strong recommendation; flip to "info" if it gets noisy.
      LOG_LEVEL = "debug";

      # Uncomment if Pinchflat sits behind a reverse proxy at a sub-path.
      # BASE_ROUTE_PATH = "/";

      # Uncomment to expose RSS feed endpoints (see upstream RSS docs).
      # EXPOSE_FEED_ENDPOINTS = "true";
    };

    # Pinchflat has no required secrets. If you later enable basic auth, wire it
    # in via sops the same way mealie/romm do (BASIC_AUTH_USERNAME / _PASSWORD).
    # environmentFiles = [ config.sops.secrets."pinchflat/env".path ];

    volumes = [
      # App config + SQLite DB (kept on local disk - WAL doesn't like NFS).
      "${dataDir}/config:/config"

      # Downloaded media on the NAS so Jellyfin etc. can read it.
      "${downloadsDir}:/downloads"
    ];
  };

  # Make sure the local bind-mount target exists with sensible ownership before
  # the container starts. Matches PUID=1000 / PGID=100 above.
  # The NAS downloads dir is provisioned on mnemosyne, not via tmpfiles here.
  systemd.tmpfiles.rules = [
    "d ${dataDir}         0755 1000 100 - -"
    "d ${dataDir}/config  0755 1000 100 - -"
  ];
}
