{ pkgs, lib, config, ... }:

# Dawarich - self-hosted location history.
# https://github.com/Freika/dawarich
#
# Points come in via Owntracks/traccar over the API; GPX exports are
# generated on demand from the UI. All persistent state lives on the VM's
# local SSD (postgres needs it, the rest is small/cheap). Exports get
# downloaded through the UI and stashed on the NAS manually.

let
  svc = config.custom.world.services.dawarich;

  # https://github.com/Freika/dawarich/releases
  dawarichVersion = "1.7.9";

  # PostGIS is mandatory since 1.7.8 (visit detection uses DBSCAN).
  # ARM64: switch to "imresamu/postgis:17-3.5-alpine".
  postgresImage = "postgis/postgis:17-3.5-alpine";
  redisImage    = "redis:7.4-alpine";

  dataDir   = "/data/dawarich";
  sharedDir = "${dataDir}/shared";  # cross-container scratch (db + redis)

  sharedEnv = {
    TZ                                = "America/New_York";
    RAILS_ENV                         = "production";
    SELF_HOSTED                       = "true";
    STORE_GEODATA                     = "true";
    RAILS_LOG_TO_STDOUT               = "true";
    PROMETHEUS_EXPORTER_ENABLED       = "false";

    DATABASE_HOST                     = "dawarich-db";
    DATABASE_PORT                     = "5432";
    DATABASE_NAME                     = "dawarich";
    DATABASE_USERNAME                 = "dawarich";

    REDIS_URL                         = "redis://dawarich-redis:6379";

    APPLICATION_HOSTS                 = svc.domain;
    APPLICATION_PROTOCOL              = "http";

    BACKGROUND_PROCESSING_CONCURRENCY = "10";
    MIN_MINUTES_SPENT_IN_CITY         = "60";
    TIME_ZONE                         = "America/New_York";
  };
in
{
  systemd.services.docker-create-dawarich-network = {
    description = "Create dawarich docker bridge network";
    after       = [ "docker.service" ];
    wantedBy    = [ "multi-user.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect dawarich-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create dawarich-network
    '';
  };

  systemd.services.docker-dawarich-app.after        = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-app.requires     = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-sidekiq.after    = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-sidekiq.requires = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-db.after         = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-db.requires      = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-redis.after      = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-redis.requires   = [ "docker-create-dawarich-network.service" ];

  # Rails web UI + API.
  virtualisation.oci-containers.containers.dawarich-app = {
    image     = "freikin/dawarich:${dawarichVersion}";
    autoStart = true;

    ports = [ "${builtins.toString svc.port}:3000" ];

    environment      = sharedEnv;
    environmentFiles = [ config.sops.templates."dawarich-env".path ];

    volumes = [
      "${dataDir}/public:/var/app/public"
      "${dataDir}/watched:/var/app/tmp/imports/watched"
      "${dataDir}/storage:/var/app/storage"
    ];

    extraOptions = [
      "--network=dawarich-network"
      "--entrypoint=web-entrypoint.sh"
    ];

    cmd = [ "bin/rails" "server" "-p" "3000" "-b" "::" ];
  };

  # Sidekiq background worker (point parsing, exports, watcher_job, etc).
  virtualisation.oci-containers.containers.dawarich-sidekiq = {
    image     = "freikin/dawarich:${dawarichVersion}";
    autoStart = true;

    environment      = sharedEnv;
    environmentFiles = [ config.sops.templates."dawarich-env".path ];

    volumes = [
      "${dataDir}/public:/var/app/public"
      "${dataDir}/watched:/var/app/tmp/imports/watched"
      "${dataDir}/storage:/var/app/storage"
    ];

    extraOptions = [
      "--network=dawarich-network"
      "--entrypoint=sidekiq-entrypoint.sh"
    ];

    cmd = [ "sidekiq" ];
  };

  # PostgreSQL + PostGIS. MUST be on local disk.
  virtualisation.oci-containers.containers.dawarich-db = {
    image     = postgresImage;
    autoStart = true;

    environment = {
      POSTGRES_USER = "dawarich";
      POSTGRES_DB   = "dawarich";
    };
    environmentFiles = [ config.sops.templates."dawarich-db-env".path ];

    volumes = [
      "${dataDir}/postgres:/var/lib/postgresql/data"
      "${sharedDir}:/var/shared"
    ];

    extraOptions = [
      "--network=dawarich-network"
      "--shm-size=1g"
    ];
  };

  # Redis for cache + sidekiq job queue.
  virtualisation.oci-containers.containers.dawarich-redis = {
    image     = redisImage;
    autoStart = true;

    volumes = [ "${sharedDir}:/data" ];

    cmd = [
      "redis-server"
      "--save" "900" "1"
      "--save" "300" "10"
      "--appendonly" "no"
    ];

    extraOptions = [ "--network=dawarich-network" ];
  };

  # Pre-create bind-mount targets so docker doesn't auto-create them on
  # first start. Ownership is intentionally root:root - DO NOT change
  # this to 1000:100 (the mealie/pinchflat/tududi pattern) because the
  # service containers enforce their own internal UIDs and will either
  # chown over the top of us or refuse to start on a mismatch:
  #
  #   * dawarich-db        postgis/postgis:17-alpine runs initdb as the
  #                        baked-in `postgres` user (UID 70). initdb
  #                        refuses to bootstrap PGDATA unless the dir
  #                        is empty AND owned by that user, and on
  #                        subsequent boots the server bails if PGDATA
  #                        ownership doesn't match.
  #   * dawarich-redis     redis:7.4-alpine runs as `redis` (UID 999)
  #                        and chowns /data itself.
  #   * dawarich-app /     freikin/dawarich runs as root inside the
  #     -sidekiq           container (Rails). No need to pre-set.
  #
  # Leaving everything as root:root lets each container fix its own
  # subtree on first start without us fighting them.
  systemd.tmpfiles.rules = [
    "d ${dataDir}          0755 root root - -"
    "d ${dataDir}/postgres 0755 root root - -"
    "d ${dataDir}/public   0755 root root - -"
    "d ${dataDir}/watched  0755 root root - -"
    "d ${dataDir}/storage  0755 root root - -"
    "d ${sharedDir}        0755 root root - -"
  ];
}
