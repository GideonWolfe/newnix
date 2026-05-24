{ pkgs, lib, config, ... }:

# Immich - self-hosted Google Photos replacement.
#
# This is a NixOS translation of the upstream docker-compose template:
#   https://docs.immich.app/install/docker-compose/
#   https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
#
# The upstream stack is 4 containers (server, machine-learning, redis, postgres)
# wired together via the default compose bridge network. We drop the
# machine-learning sidecar here because the VM hosting this stack doesn't have
# the CPU/RAM budget for the CLIP/face models - the server is configured with
# IMMICH_MACHINE_LEARNING_ENABLED=false so smart-search/face-recognition is
# disabled but everything else works. Add the ML container back later if you
# move this to beefier hardware.
#
# ---------------------------------------------------------------------------
# Storage layout
# ---------------------------------------------------------------------------
# By default Immich writes everything - originals AND generated content - under
# a single UPLOAD_LOCATION:
#
#   UPLOAD_LOCATION/
#   |-- upload/<userID>/       <- buffer for newly-uploaded originals
#   |-- library/<userID>/      <- final home of originals (Storage Template ON)
#   |-- profile/<userID>/      <- user avatars
#   |-- thumbs/<userID>/       <- preview + face thumbnails
#   |-- encoded-video/<userID> <- re-encoded videos
#   +-- backups/               <- automatic DB dumps
#
# Only the ORIGINALS need to live on the NAS - everything else is either
# regenerable (thumbs, encoded-video) or transient (upload buffer, DB dumps).
# Keeping that scratch space on the VM's local SSD matches the pattern romm/
# mealie already use (app state on /data, media on /nas/tank/media/*) and
# avoids bouncing every byte of generated content over NFS.
#
# So this module uses two paths:
#
#   * dataDir    /data/immich on the VM's local SSD. Holds postgres data AND
#                UPLOAD_LOCATION (uploadDir below = ${dataDir}/data). Everything
#                that isn't an original lives here: the upload buffer, thumbs,
#                encoded-video, profile pics, automatic DB dumps.
#
#   * libraryDir /nas/tank/personal/photos on the NAS. Bind-mounted at
#                /data/library inside the container, so the Storage Template
#                engine writes originals straight to the NAS. This is the only
#                folder whose contents cross the NFS boundary.
#
# Upload flow for one photo:
#   phone -> immich-server -> ${uploadDir}/upload/<userID>/  (local SSD)
#         -> storage template job
#         -> ${libraryDir}/<userID>/2026/2026-05-23/IMG.jpg  (one NFS write)
#
# Because uploadDir (local) and libraryDir (NFS) are different filesystems,
# the template-engine "move" is technically a copy+unlink. That's fine: the
# file has to land on NFS eventually anyway, so it's exactly one NFS write
# per photo either way.
#
# Bootstrap workflow (one-time, from a workstation):
#   1. Bring this stack up; create your admin user in the web UI.
#   2. Admin -> Settings -> Storage Template:
#        - turn the template engine ON
#        - pick a template, e.g. {{y}}/{{y}}-{{MM}}-{{dd}}/{{filename}}
#   3. From your workstation, point the Immich CLI at your messy archive:
#        nix run nixpkgs#immich-cli -- login http://<vm_app1>:2283 <api-key>
#        nix run nixpkgs#immich-cli -- upload --recursive ~/personal/archives
#      The CLI hashes files client-side and skips anything already in the
#      library, so re-runs are idempotent and duplicate copies of the same
#      photo only ever land once.
#   4. Use Immich's web UI (Explore -> Duplicates) to dedupe near-duplicates
#      and delete memes. Anything you delete in Immich is removed from
#      libraryDir too, so /personal/photos stays curated.
#   5. From then on, the mobile app keeps backing up new photos via the same
#      upload pipeline, and they land in libraryDir alongside the bootstrap.
#
# Bind mount layout (host -> container):
#   ${uploadDir}                    -> /data                              (server)
#   ${libraryDir}                   -> /data/library                      (server)
#   /etc/localtime                  -> /etc/localtime              (ro)   (server)
#   ${dataDir}/postgres             -> /var/lib/postgresql/data           (database)
#
# IMPORTANT (upstream guidance):
#   * The postgres data dir MUST live on a local disk - "Network shares are not
#     supported for the database" - so it stays under /data on the VM.
let
  svc = config.custom.world.services.immich;

  # Pin the Immich application version.
  # See https://github.com/immich-app/immich/releases for the latest release.
  immichVersion = "v2.7.5";

  # Pinned support images straight from the v2.7.5 docker-compose.yml. These
  # rarely change between Immich releases, but the upstream compose pins exact
  # digests so we do too.
  redisImage = "docker.io/valkey/valkey:9@sha256:3b55fbaa0cd93cf0d9d961f405e4dfcc70efe325e2d84da207a0a8e6d8fde4f9";
  postgresImage = "ghcr.io/immich-app/postgres:14-vectorchord0.4.3-pgvectors0.2.0@sha256:bcf63357191b76a916ae5eb93464d65c07511da41e3bf7a8416db519b40b1c23";

  # Local app state. Holds both the postgres data dir AND Immich's UPLOAD_LOCATION
  # (uploadDir below). Lives on the VM's data disk - same pattern romm/mealie use.
  dataDir = "/data/immich";

  # Immich's managed scratch space (UPLOAD_LOCATION). Holds the upload buffer,
  # thumbnails, transcoded video, profile pics, and automatic DB dumps - i.e.
  # everything EXCEPT the originals (those live in libraryDir below). All of
  # that content is either regenerable or transient, so it stays on local SSD
  # instead of round-tripping over NFS.
  uploadDir = "${dataDir}/data";

  # The on-disk home of the user's curated photo library. Bind-mounted at
  # /data/library inside the container so the Storage Template engine places
  # originals here, organized by date. Phone uploads end up here too. This
  # folder will only ever contain photo/video originals - no Immich metadata,
  # no thumbnails, no DB dumps.
  libraryDir = "/nas/tank/personal/photos";
in
{
  # Ensure the immich docker network exists on this host. Same one-shot pattern
  # we use for romm so the auto-generated docker-*.service units don't race.
  systemd.services.docker-create-immich-network = {
    description = "Create immich docker bridge network";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      # Keep the unit "active (exited)" after success so dependent units see
      # the dependency as satisfied.
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect immich-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create immich-network
    '';
  };

  # Make the auto-generated container units wait for the network to exist.
  systemd.services.docker-immich-server.after = [ "docker-create-immich-network.service" ];
  systemd.services.docker-immich-server.requires = [ "docker-create-immich-network.service" ];
  systemd.services.docker-immich-redis.after = [ "docker-create-immich-network.service" ];
  systemd.services.docker-immich-redis.requires = [ "docker-create-immich-network.service" ];
  systemd.services.docker-immich-database.after = [ "docker-create-immich-network.service" ];
  systemd.services.docker-immich-database.requires = [ "docker-create-immich-network.service" ];

  ##############################################################################
  # immich-server - API + web UI                                               #
  ##############################################################################
  virtualisation.oci-containers.containers.immich-server = {
    image = "ghcr.io/immich-app/immich-server:${immichVersion}";
    autoStart = true;

    # Map the host port (from world.services) to the container's internal 2283.
    ports = [ "${builtins.toString svc.port}:2283" ];

    environment = {
      TZ = "America/New_York";

      # The upstream compose lets the server discover redis/database via the
      # default compose service names ("redis", "database"). Our containers
      # are named immich-redis / immich-database, so override the defaults.
      # See https://docs.immich.app/install/environment-variables
      REDIS_HOSTNAME = "immich-redis";
      DB_HOSTNAME = "immich-database";
      DB_USERNAME = "postgres";
      DB_DATABASE_NAME = "immich";

      # No machine-learning container in this deployment (the VM hosting this
      # stack isn't beefy enough for the CLIP/face models). Turning the flag
      # off here means smart-search and face recognition won't run, but the
      # rest of Immich (upload, library, albums, sharing) works fine.
      # See https://docs.immich.app/install/environment-variables
      IMMICH_MACHINE_LEARNING_ENABLED = "false";
    };

    volumes = [
      # Immich's managed scratch space (UPLOAD_LOCATION). Holds the upload
      # buffer, thumbs, encoded-video, profile pics, and automatic DB dumps.
      "${uploadDir}:/data"

      # The user's curated photo library. With the Storage Template engine ON,
      # the immich-server moves originals from /data/upload/<userID>/ into
      # /data/library/<userID>/<template-path>/ after every upload. Because
      # /data/library is its own bind mount, the originals physically live in
      # libraryDir and the personal/photos folder ends up as a clean, dated
      # snapshot of the full photo archive.
      "${libraryDir}:/data/library"

      # Keep container clock in sync with the host (mirrors upstream compose).
      "/etc/localtime:/etc/localtime:ro"
    ];

    extraOptions = [ "--network=immich-network" ];

    # Order container start the way docker-compose does.
    dependsOn = [ "immich-redis" "immich-database" ];

    # DB_PASSWORD comes from sops; see ./secrets/secrets_immich.nix
    environmentFiles = [ config.sops.templates."immich-env".path ];
  };

  ##############################################################################
  # immich-redis - Valkey (Redis drop-in)                                      #
  ##############################################################################
  virtualisation.oci-containers.containers.immich-redis = {
    image = redisImage;
    autoStart = true;
    extraOptions = [ "--network=immich-network" ];
  };

  ##############################################################################
  # immich-database - Postgres 14 + VectorChord + pgvector                     #
  ##############################################################################
  virtualisation.oci-containers.containers.immich-database = {
    image = postgresImage;
    autoStart = true;

    environment = {
      POSTGRES_USER = "postgres";
      POSTGRES_DB = "immich";
      POSTGRES_INITDB_ARGS = "--data-checksums";
      # Uncomment if the postgres dir is NOT on SSD:
      # DB_STORAGE_TYPE = "HDD";
    };

    volumes = [
      # MUST be on local disk (per upstream docs); ${dataDir} lives under /data.
      "${dataDir}/postgres:/var/lib/postgresql/data"
    ];

    extraOptions = [
      "--network=immich-network"
      # Upstream sets shm_size: 128mb; postgres uses /dev/shm for parallel
      # workers and tempfiles, so match it.
      "--shm-size=128m"
    ];

    # POSTGRES_PASSWORD comes from sops; see ./secrets/secrets_immich.nix
    environmentFiles = [ config.sops.templates."immich-db-env".path ];
  };

  # Pre-create the bind-mount targets with 1000:100 ownership so docker (which
  # runs as root) doesn't create them as root on first start. Matches the same
  # pattern used by romm/mealie/cwa.
  #
  # The postgres directory is intentionally omitted - postgres' entrypoint
  # expects to chown its data dir to the in-container postgres user (999:999),
  # so we let docker create it as root and postgres fix it up on init. Same
  # treatment we give romm_database in romm.nix.
  #
  # libraryDir lives on the NAS (provisioned on mnemosyne), so it's not
  # tmpfiles' job - just make sure /nas/tank/personal/photos is
  # chown 1000:100 over there.
  systemd.tmpfiles.rules = [
    "d ${dataDir}    0755 1000 100 - -"
    "d ${uploadDir}  0755 1000 100 - -"
  ];
}
