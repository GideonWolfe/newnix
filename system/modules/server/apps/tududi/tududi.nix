{ pkgs, lib, config, ... }:

# Tududi - self-hosted GTD-style task / project / notes manager with a
# PostgreSQL database, a REST API, and built-in CalDAV so
# Apple Reminders / tasks.org / Thunderbird can sync natively.
#
# Upstream:        https://github.com/chrisvel/tududi
# Container image: docker.io/chrisvel/tududi
# Default port:    3002 (http, express)
#
# Bind mount layout (host -> container):
#   /data/tududi/postgres -> /var/lib/postgresql/data
#   /data/tududi/uploads  -> /app/uploads
#   /data/tududi/backups  -> /app/backups
#                            (including the Restic database dump under db/)
let
  svc = config.custom.world.services.tududi;
  dataDir = "/data/tududi";
  origin = "${svc.protocol}://${svc.ip}:${builtins.toString svc.port}";
in
{
  # Keep the database private to the application bridge and wait for it to
  # accept connections before starting Tududi.
  systemd.services.docker-create-tududi-network = {
    description = "Create Tududi Docker bridge network";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      until ${pkgs.docker}/bin/docker info >/dev/null 2>&1; do sleep 1; done
      ${pkgs.docker}/bin/docker network inspect tududi-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create tududi-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network inspect tududi-network >/dev/null 2>&1
    '';
  };

  systemd.services.docker-tududi-db.after = [ "docker-create-tududi-network.service" ];
  systemd.services.docker-tududi-db.requires = [ "docker-create-tududi-network.service" ];

  systemd.services.docker-tududi-db-ready = {
    description = "Wait for Tududi PostgreSQL to accept connections";
    after = [ "docker-tududi-db.service" ];
    requires = [ "docker-tududi-db.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for attempt in $(seq 1 60); do
        if ${pkgs.docker}/bin/docker exec tududi-db pg_isready -U tududi -d tududi >/dev/null 2>&1; then
          exit 0
        fi
        sleep 1
      done
      echo "Tududi PostgreSQL did not become ready within 60 seconds" >&2
      exit 1
    '';
  };

  systemd.services.docker-tududi.after = [
    "docker-create-tududi-network.service"
    "docker-tududi-db-ready.service"
  ];
  systemd.services.docker-tududi.requires = [
    "docker-create-tududi-network.service"
    "docker-tududi-db-ready.service"
  ];

  virtualisation.oci-containers.containers.tududi = {
    image = "chrisvel/tududi:2.1.0";
    autoStart = true;

    # Publish the host port (from world.services) to the container's
    # internal 3002. Same number on both sides keeps the upstream docs
    # directly applicable.
    ports = [ "${builtins.toString svc.port}:3002" ];

    environment = {
      TZ = "America/New_York";

      PUID = "1000";
      PGID = "100";

      TUDUDI_USER_EMAIL = "gideon@gideonwolfe.xyz";
      BASE_URL = origin;
      TUDUDI_ALLOWED_ORIGINS = origin;
      TUDUDI_TRUST_PROXY = "false";
      CALDAV_ENABLED = "true";
    };

    environmentFiles = [ config.sops.templates."tududi-env".path ];

    volumes = [
      "${dataDir}/uploads:/app/uploads"
      "${dataDir}/backups:/app/backups"
    ];

    extraOptions = [ "--network=tududi-network" ];
  };

  virtualisation.oci-containers.containers.tududi-db = {
    # Matches Tududi's recommended Compose database version.
    image = "postgres:16-alpine";
    autoStart = true;

    environment = {
      POSTGRES_DB = "tududi";
      POSTGRES_USER = "tududi";
    };
    environmentFiles = [ config.sops.templates."tududi-db-env".path ];

    volumes = [ "${dataDir}/postgres:/var/lib/postgresql/data" ];

    extraOptions = [ "--network=tududi-network" ];
  };

  # PostgreSQL's entrypoint manages ownership of its data directory. Tududi
  # runs as the configured PUID/PGID and needs writable upload/backup paths.
  systemd.tmpfiles.rules = [
    "d ${dataDir}             0755 root root - -"
    "d ${dataDir}/postgres    0755 root root - -"
    "d ${dataDir}/uploads     0755 1000 100 - -"
    "d ${dataDir}/backups     0755 1000 100 - -"
    "d ${dataDir}/backups/db  0700 1000 100 - -"
  ];
}
