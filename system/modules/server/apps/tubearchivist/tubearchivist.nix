{ pkgs, lib, config, ... }:

# TubeArchivist - self-hosted YouTube media archiver with metadata, search,
# and a web UI on top of Elasticsearch.
#   https://github.com/tubearchivist/tubearchivist
#
# Faithful port of the upstream docker-compose.yml. Three containers on a
# dedicated docker bridge so they can resolve each other by name:
#   - tubearchivist    Django app + UI (port 8000)
#   - archivist-es     Elasticsearch (bbilly1/tubearchivist-es)
#   - archivist-redis  Redis broker/cache
#
# Persistent state lives under /data/tubearchivist on the VM's data disk:
#   media/  -> downloaded videos + thumbnails
#   cache/  -> TA cache (artwork, transcoding scratch)
#   redis/  -> Redis AOF/RDB
#   es/     -> Elasticsearch indices (HEAVY - watch disk usage)
#
# Secrets (TA_PASSWORD, ELASTIC_PASSWORD) are wired in via sops templates
# in ./secrets/secrets_tubearchivist.nix. ELASTIC_PASSWORD must match
# between the TA container and the ES container.


let
  svc = config.custom.world.services.tubearchivist;

  # Pin image versions so a stray `docker pull` doesn't pick up an
  # incompatible TA <-> ES pair (TA is sensitive to ES major versions).
  taImage    = "bbilly1/tubearchivist:v0.5.4";
  esImage    = "bbilly1/tubearchivist-es:8.19.0";
  redisImage = "redis:7-alpine";

  dataDir  = "/data/tubearchivist";
  mediaDir = "/nas/tank/media/youtube";
  cacheDir = "${dataDir}/cache";
  redisDir = "${dataDir}/redis";
  esDir    = "${dataDir}/es";
in
{
  # Dedicated bridge so TA can reach `archivist-es` / `archivist-redis`
  # by container name, matching the upstream compose file.
  systemd.services.docker-create-tubearchivist-network = {
    description = "Create tubearchivist docker bridge network";
    after       = [ "docker.service" ];
    wantedBy    = [ "multi-user.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect tubearchivist-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create tubearchivist-network
    '';
  };

  systemd.services.docker-tubearchivist.after          = [ "docker-create-tubearchivist-network.service" ];
  systemd.services.docker-tubearchivist.requires       = [ "docker-create-tubearchivist-network.service" ];
  systemd.services.docker-archivist-es.after           = [ "docker-create-tubearchivist-network.service" ];
  systemd.services.docker-archivist-es.requires        = [ "docker-create-tubearchivist-network.service" ];
  systemd.services.docker-archivist-redis.after        = [ "docker-create-tubearchivist-network.service" ];
  systemd.services.docker-archivist-redis.requires     = [ "docker-create-tubearchivist-network.service" ];

  # ---- tubearchivist (web/app) ----------------------------------------
  virtualisation.oci-containers.containers.tubearchivist = {
    image     = taImage;
    autoStart = true;

    ports = [ "${builtins.toString svc.port}:8000" ];

    environment = {
      # Cross-container endpoints (resolved on the TA bridge network).
      ES_URL    = "http://archivist-es:9200";
      REDIS_CON = "redis://archivist-redis:6379";

      # Drop privs inside the container to match the host bind-mount owner.
      HOST_UID = "1000";
      HOST_GID = "100";

      # Public-facing URL TA uses to build absolute links. LAN-only for now,
      # so point at the VM directly. Update when fronted by Traefik.
      TA_HOST = "${svc.protocol}://${svc.ip}:${builtins.toString svc.port}";

      # Initial admin username. The password comes in via the sops env file.
      TA_USERNAME = "gideon";

      TZ = "America/New_York";
    };
    # TA_PASSWORD + ELASTIC_PASSWORD come from the sops template.
    environmentFiles = [ config.sops.templates."tubearchivist-env".path ];

    volumes = [
      "${mediaDir}:/youtube"
      "${cacheDir}:/cache"
    ];

    extraOptions = [
      "--network=tubearchivist-network"
      "--hostname=tubearchivist"
    ];

    dependsOn = [ "archivist-es" "archivist-redis" ];
  };

  # ---- archivist-es (Elasticsearch) -----------------------------------
  virtualisation.oci-containers.containers.archivist-es = {
    image     = esImage;
    autoStart = true;

    environment = {
      "ES_JAVA_OPTS"            = "-Xms1g -Xmx1g";
      "xpack.security.enabled"  = "true";
      "discovery.type"          = "single-node";
      "path.repo"               = "/usr/share/elasticsearch/data/snapshot";
    };
    # ELASTIC_PASSWORD must match TA's copy - both come from the same key.
    environmentFiles = [ config.sops.templates."tubearchivist-env".path ];

    volumes = [
      "${esDir}:/usr/share/elasticsearch/data"
    ];

    # Upstream compose sets memlock unlimited; mirror that or ES will
    # warn / refuse to start with mlockall enabled.
    extraOptions = [
      "--network=tubearchivist-network"
      "--hostname=archivist-es"
      "--ulimit=memlock=-1:-1"
    ];
  };

  # ---- archivist-redis -------------------------------------------------
  virtualisation.oci-containers.containers.archivist-redis = {
    image     = redisImage;
    autoStart = true;

    volumes = [
      "${redisDir}:/data"
    ];

    extraOptions = [
      "--network=tubearchivist-network"
      "--hostname=archivist-redis"
    ];

    dependsOn = [ "archivist-es" ];
  };

  # Pre-create bind-mount targets. TA + Redis happily run as 1000:100
  # (matches HOST_UID/HOST_GID above), but the upstream ES image runs as
  # uid 1000 inside the container and chowns its own data dir on first
  # start - we just need the directory to exist and be writable.
  systemd.tmpfiles.rules = [
    "d ${dataDir}  0755 1000 100  - -"
    "d ${mediaDir} 0755 1000 100  - -"
    "d ${cacheDir} 0755 1000 100  - -"
    "d ${redisDir} 0755 1000 100  - -"
    "d ${esDir}    0755 1000 1000 - -"
  ];
}
