{ pkgs, lib, config, ... }:

# Tududi - self-hosted GTD-style task / project / notes manager with a real
# server-side SQLite DB, a REST API, and (importantly) built-in CalDAV so
# Apple Reminders / tasks.org / Thunderbird can sync natively.
#
# Upstream:        https://github.com/chrisvel/tududi
# Container image: docker.io/chrisvel/tududi
# Default port:    3002 (http, express)
#
# Trial mode (vm_test):
#   * Admin email / password / session secret are wired in as plain
#     `environment` values here. This is fine for a LAN-only sandbox VM,
#     but if/when this is promoted to vm_app1 these MUST move into sops
#     (see system/modules/server/apps/karakeep/secrets/ for the pattern).
#     The session secret in particular is bootstrapping cookie signing,
#     so rotating it later just invalidates current sessions - no DB
#     damage.
#   * The admin password below is the *initial* admin password. Change it
#     in the web UI immediately after first login (Settings -> Profile).
#     After that the value here is effectively unused; tududi reads from
#     its SQLite users table.
#
# Bind mount layout (host -> container):
#   /data/tududi/db       -> /app/backend/db        (SQLite + sessions)
#   /data/tududi/uploads  -> /app/backend/uploads   (user attachments)
let
  svc = config.custom.world.services.tududi;
  dataDir = "/data/tududi";
in
{
  virtualisation.oci-containers.containers.tududi = {
    # Docker Hub tags drop the `v` prefix even though the git tags have it
    # (i.e. git `v1.1.0-rc.3` -> docker `1.1.0-rc.3`). Check available tags:
    #   https://hub.docker.com/r/chrisvel/tududi/tags
    image = "chrisvel/tududi:1.1.0-rc.3";
    autoStart = true;

    # Publish the host port (from world.services) to the container's
    # internal 3002. Same number on both sides keeps the upstream docs
    # directly applicable.
    ports = [ "${builtins.toString svc.port}:3002" ];

    environment = {
      TZ = "America/New_York";

      PUID = "1000";
      PGID = "100";

      # ---- Bootstrap admin (trial only - change on first login) -------
      # These three are only read by the container on first start to
      # seed the initial admin user + cookie signer. After first login
      # the password is managed in the DB.
      TUDUDI_USER_EMAIL = "gideon@gideonwolfe.xyz";
      # FIXME(sops): rotate + move to sops before promoting off vm_test.
      TUDUDI_USER_PASSWORD = "changeme-on-first-login";
      # FIXME(sops): same. `openssl rand -hex 64` when migrating.
      TUDUDI_SESSION_SECRET =
        "trial-mode-session-secret-rotate-me-before-promotion-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa";

      # We're hitting it directly over LAN; not behind a proxy yet.
      # When fronted by Traefik on vm-ingress, flip this to "true" and
      # set TUDUDI_ALLOWED_ORIGINS to the public origin.
      TUDUDI_TRUST_PROXY = "false";

      # As of 1.1.0, tududi enforces CSRF + CORS strictly: requests whose
      # `Origin` header isn't in TUDUDI_ALLOWED_ORIGINS get rejected by
      # the middleware before they ever hit a route. The image default
      # only whitelists localhost:{3002,8080}, so LAN access from a
      # browser at http://<vm_test ip>:3002 silently fails (login POST
      # 403s, the SPA renders blank). Whitelist the exact origin we use.
      #
      # When this moves to vm_app1 + Traefik, replace with the public
      # https://tududi.gideonwolfe.xyz origin (or comma-separate both).
      TUDUDI_ALLOWED_ORIGINS = "${svc.protocol}://${svc.ip}:${builtins.toString svc.port}";

      CALDAV_ENABLED = "true";
    };

    volumes = [
      # SQLite DB + session store. This is the source of truth - back it
      # up with restic once we promote off the sandbox.
      "${dataDir}/db:/app/backend/db"
      # User-uploaded attachments (note images, etc).
      "${dataDir}/uploads:/app/backend/uploads"
    ];
  };

  # Pre-create the bind-mount targets with gideon:users (1000:100) 
  systemd.tmpfiles.rules = [
    "d ${dataDir}          0755 1000 100 - -"
    "d ${dataDir}/db       0750 1000 100 - -"
    "d ${dataDir}/uploads  0755 1000 100 - -"
  ];
}
