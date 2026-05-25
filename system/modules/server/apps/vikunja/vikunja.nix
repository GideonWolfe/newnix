{ pkgs, lib, config, ... }:

# Vikunja - self-hosted to-do / task / project / kanban app. Single Go
# binary, frontend + backend bundled in one container. Has CalDAV built
# in since v0.20 so Apple Reminders / tasks.org / Thunderbird can sync.
#
# Upstream:        https://vikunja.io
# Source:          https://code.vikunja.io/vikunja
# Container image: docker.io/vikunja/vikunja
# Default port:    3456 (http)
#
# Trial mode notes (vm_test):
#   * Backed by SQLite at /data/vikunja/db/vikunja.db. Single-user
#     workload doesn't need postgres - keeps the moving parts to one
#     container.
#   * VIKUNJA_SERVICE_SECRET is wired in as a plain `environment` value
#     here. Fine for the LAN-only sandbox; if/when this is promoted to
#     vm_app1 the secret MUST move into sops (see the karakeep secrets/
#     dir for the pattern). Rotating the secret invalidates all login
#     sessions but doesn't damage data.
#   * VIKUNJA_SERVICE_PUBLICURL must match exactly what the browser
#     types into the address bar - vikunja's frontend reads this at
#     bootstrap to know where to send API calls. If you ever access the
#     instance from a different host/port, update this or the SPA will
#     stall.
#   * No HSTS / forced-HTTPS upgrade nonsense (looking at you, tududi) -
#     vikunja is happy on plain HTTP for LAN use. TLS, when we want it,
#     is the proxy's job.
#
# Bind mount layout (host -> container):
#   /data/vikunja/db     -> /db                       (SQLite DB)
#   /data/vikunja/files  -> /app/vikunja/files        (attachments)
let
  svc = config.custom.world.services.vikunja;
  dataDir = "/data/vikunja";

  # Browser-visible URL. Has to match what we type into the address bar
  # (LAN IP + host port) because vikunja's JS bundle uses this to figure
  # out where /api lives. No trailing slash.
  publicUrl = "${svc.protocol}://${svc.ip}:${builtins.toString svc.port}";
in
{
  virtualisation.oci-containers.containers.vikunja = {
    # Pin a stable release tag rather than `latest` so an unattended
    # `docker pull` doesn't drag in a breaking upgrade. Bump deliberately.
    # Available tags: https://hub.docker.com/r/vikunja/vikunja/tags
    image = "vikunja/vikunja:2.3.0";
    autoStart = true;

    # Publish host port (from world.services) to the container's 3456.
    ports = [ "${builtins.toString svc.port}:3456" ];

    environment = {
      TZ = "America/New_York";

      # Use SQLite (default would be postgres expecting a sibling
      # container). Path is inside the container; the volume below maps
      # it onto the host's data disk.
      VIKUNJA_DATABASE_TYPE = "sqlite";
      VIKUNJA_DATABASE_PATH = "/db/vikunja.db";

      # Where the browser reaches this instance. See `publicUrl` above.
      VIKUNJA_SERVICE_PUBLICURL = publicUrl;

      # FIXME(sops): rotate + move to sops before promoting off vm_test.
      # `openssl rand -hex 32` when migrating. Used to sign JWTs.
      VIKUNJA_SERVICE_SECRET =
        "trial-mode-vikunja-secret-rotate-me-before-promotion-aaaaaaaaaaaaaaaa";

      # Lock down user registration once we're past the trial - flip this
      # to "false" after creating the gideon account through the UI.
      VIKUNJA_SERVICE_ENABLEREGISTRATION = "true";
    };

    volumes = [
      # SQLite DB lives here. Source of truth - back up with restic when
      # we promote off the sandbox.
      "${dataDir}/db:/db"
      # User attachments (task files, avatars, backgrounds).
      "${dataDir}/files:/app/vikunja/files"
    ];
  };

  # Vikunja runs as UID 1000 inside the container (matches host gideon)
  # and explicitly will NOT chown its files dir itself - upstream docs
  # tell us to do it ourselves. 1000:100 keeps the data host-readable
  # without sudo, same pattern as mealie / pinchflat / romm / tududi.
  systemd.tmpfiles.rules = [
    "d ${dataDir}        0755 1000 100 - -"
    "d ${dataDir}/db     0750 1000 100 - -"
    "d ${dataDir}/files  0755 1000 100 - -"
  ];
}
