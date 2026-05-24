{ pkgs, lib, config, ... }:

# Dawarich - self-hosted location history & trip tracking.
# https://github.com/Freika/dawarich
#
# Stack: dawarich_app (Rails) + dawarich_sidekiq (background jobs)
#        + postgres + redis, all on a dedicated bridge network.
#
# ---------------------------------------------------------------------------
# Storage layout  (mirrors the CWA ingest/library split)
# ---------------------------------------------------------------------------
# Dawarich has three persistent directories besides the database:
#
#   public   /var/app/public
#            Rails static assets (JS/CSS/images). Small and fully regenerable.
#            Lives on local SSD.
#
#   watched  /var/app/tmp/imports/watched
#            The INTAKE QUEUE. Drop a GPX/GeoJSON/OwnTracks file here and
#            sidekiq picks it up, parses the GPS points into postgres, then
#            moves the raw file into Active Storage (storageDir below).
#            Think of this as CWA's /cwa-book-ingest - files are transient.
#            Lives on local SSD so sidekiq gets fast inotify events.
#
#   storage  /var/app/storage
#            Rails Active Storage - the PERMANENT home of every raw track file
#            uploaded through the UI or moved here from the watched folder.
#            This is what grows over time and is the source-of-truth for raw
#            track files. Lives on the NAS.
#
# Bind mount layout (host → container):
#   ${dataDir}/public    → /var/app/public             (app + sidekiq)
#   ${dataDir}/watched   → /var/app/tmp/imports/watched (app + sidekiq)
#   ${storageDir}        → /var/app/storage             (app + sidekiq)
#   ${dataDir}/postgres  → /var/lib/postgresql/data     (db)

let
  svc = config.custom.world.services.dawarich;

  dawarichVersion = "0.26.6";

  # Scratch / app state on the VM's local SSD.
  dataDir = "/data/dawarich";

  # Permanent store of raw track files on the NAS (= Active Storage).
  # This is the source-of-truth for uploaded GPX / GeoJSON / OwnTracks files.
  storageDir = "/nas/tank/personal/gps-history";

  # Shared environment passed to both app + sidekiq containers.
  sharedEnv = {
    TZ                                = "America/New_York";
    RAILS_ENV                         = "production";
    DATABASE_HOST                     = "dawarich-db";
    DATABASE_NAME                     = "dawarich";
    DATABASE_USERNAME                 = "dawarich";
    REDIS_URL                         = "redis://dawarich-redis:6379/0";
    APPLICATION_HOSTS                 = svc.domain;
    BACKGROUND_PROCESSING_CONCURRENCY = "10";
    MIN_MINUTES_SPENT_IN_CITY         = "60";
    TIME_ZONE                         = "America/New_York";
  };
in
{
  # Dedicated bridge network so containers resolve each other by name.
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

  # All containers wait for the network unit.
  systemd.services.docker-dawarich-app.after    = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-app.requires = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-sidekiq.after    = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-sidekiq.requires = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-db.after    = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-db.requires = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-redis.after    = [ "docker-create-dawarich-network.service" ];
  systemd.services.docker-dawarich-redis.requires = [ "docker-create-dawarich-network.service" ];

  ##############################################################################
  # dawarich-app - web UI + API                                                #
  ##############################################################################
  virtualisation.oci-containers.containers.dawarich-app = {
    image     = "freikin/dawarich:${dawarichVersion}";
    autoStart = true;

    ports = [ "${builtins.toString svc.port}:3000" ];

    environment = sharedEnv;
    environmentFiles = [ config.sops.templates."dawarich-env".path ];

    volumes = [
      # Static Rails assets - small and regenerable, local SSD is fine.
      "${dataDir}/public:/var/app/public"
      # Intake queue - drop GPX/GeoJSON files here to trigger auto-import.
      # Stays on SSD so sidekiq gets fast inotify notifications.
      "${dataDir}/watched:/var/app/tmp/imports/watched"
      # Active Storage - permanent home of all uploaded raw track files.
      # Lives on the NAS; this is what grows over time.
      "${storageDir}:/var/app/storage"
    ];

    extraOptions = [ "--network=dawarich-network" ];

    cmd = [ "bin/rails" "server" "-b" "0.0.0.0" "-p" "3000" ];
  };

  ##############################################################################
  # dawarich-sidekiq - background job processor                                #
  ##############################################################################
  virtualisation.oci-containers.containers.dawarich-sidekiq = {
    image     = "freikin/dawarich:${dawarichVersion}";
    autoStart = true;

    environment = sharedEnv;
    environmentFiles = [ config.sops.templates."dawarich-env".path ];

    volumes = [
      "${dataDir}/public:/var/app/public"
      # Sidekiq is the process that actually consumes the watched folder,
      # parses the GPS points into postgres, then moves the raw file to storage.
      "${dataDir}/watched:/var/app/tmp/imports/watched"
      "${storageDir}:/var/app/storage"
    ];

    extraOptions = [ "--network=dawarich-network" ];

    cmd = [ "bundle" "exec" "sidekiq" ];
  };

  ##############################################################################
  # dawarich-db - PostgreSQL                                                   #
  ##############################################################################
  virtualisation.oci-containers.containers.dawarich-db = {
    image     = "postgres:17-alpine";
    autoStart = true;

    environment = {
      POSTGRES_USER = "dawarich";
      POSTGRES_DB   = "dawarich";
    };
    environmentFiles = [ config.sops.templates."dawarich-db-env".path ];

    volumes = [
      # MUST be on local disk (network shares not supported by postgres).
      "${dataDir}/postgres:/var/lib/postgresql/data"
    ];

    extraOptions = [ "--network=dawarich-network" ];
  };

  ##############################################################################
  # dawarich-redis - job queue                                                 #
  ##############################################################################
  virtualisation.oci-containers.containers.dawarich-redis = {
    image     = "redis:7-alpine";
    autoStart = true;

    extraOptions = [ "--network=dawarich-network" ];
  };

  # Pre-create local SSD directories.
  # storageDir lives on the NAS and must be provisioned there (like
  # libraryDir in immich / the calibre library) - not tmpfiles' job.
  systemd.tmpfiles.rules = [
    "d ${dataDir}          0755 root root - -"
    "d ${dataDir}/postgres 0755 root root - -"
    "d ${dataDir}/public   0755 root root - -"
    "d ${dataDir}/watched  0755 root root - -"
  ];
}