{ config, pkgs, ... }:

# https://youtarr.com/ — app + MariaDB on a private Docker bridge.
# Keep application state on local ext4; only downloaded media belongs on NFS.
let
  svc = config.custom.world.services.youtarr;
  dataDir = "/data/youtarr";
  mediaDir = "/nas/tank/media/youtube";
  uid = "1000";
  gid = "100";
in
{
  systemd.services.docker-create-youtarr-network = {
    description = "Create youtarr docker bridge network";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect youtarr-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create youtarr-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network inspect youtarr-network >/dev/null
    '';
  };

  systemd.services.docker-youtarr = {
    after = [ "docker-create-youtarr-network.service" ];
    requires = [ "docker-create-youtarr-network.service" ];
    # Fail closed if either disk is unavailable instead of writing below an unmounted path.
    unitConfig.RequiresMountsFor = [ dataDir mediaDir ];
    preStart = ''
      # Create as the media owner, not NFS-squashed root; leave existing content untouched.
      ${pkgs.util-linux}/bin/setpriv --reuid=${uid} --regid=${gid} --clear-groups \
        ${pkgs.coreutils}/bin/mkdir -p ${mediaDir}
      ${pkgs.util-linux}/bin/setpriv --reuid=${uid} --regid=${gid} --clear-groups \
        ${pkgs.coreutils}/bin/test -w ${mediaDir}
    '';
  };

  systemd.services.docker-youtarr-db = {
    after = [ "docker-create-youtarr-network.service" ];
    requires = [ "docker-create-youtarr-network.service" ];
    unitConfig.RequiresMountsFor = [ dataDir ];
  };

  virtualisation.oci-containers.containers.youtarr = {
    image = "dialmaster/youtarr:v1.87.0";
    autoStart = true;
    # Upstream uses Docker's user setting, not PUID/PGID environment variables.
    user = "${uid}:${gid}";
    ports = [ "${svc.ip}:${builtins.toString svc.port}:3011" ];

    environment = {
      TZ = config.time.timeZone;
      DB_HOST = "youtarr-db";
      DB_PORT = "3306";
      DB_USER = "youtarr";
      DB_NAME = "youtarr";
      AUTH_ENABLED = "true";
      TRUST_PROXY = "false";
      LOG_LEVEL = "info";
      # Informational host path; the bind mount below controls the download location.
      YOUTUBE_OUTPUT_DIR = mediaDir;
    };
    environmentFiles = [ config.sops.templates."youtarr-env".path ];

    volumes = [
      "${dataDir}/config:/app/config"
      "${dataDir}/jobs:/app/jobs"
      "${dataDir}/images:/app/server/images"
      "${mediaDir}:/usr/src/app/data"
    ];
    extraOptions = [ "--network=youtarr-network" ];
    # The upstream entrypoint also retries authenticated DB connections before starting.
    dependsOn = [ "youtarr-db" ];
  };

  virtualisation.oci-containers.containers.youtarr-db = {
    # Supported LTS series rather than upstream Compose's end-of-life MariaDB 10.3.
    image = "mariadb:11.4";
    autoStart = true;
    environment = {
      MARIADB_DATABASE = "youtarr";
      MARIADB_USER = "youtarr";
    };
    environmentFiles = [ config.sops.templates."youtarr-db-env".path ];
    volumes = [ "${dataDir}/database:/var/lib/mysql" ];
    cmd = [
      "--character-set-server=utf8mb4"
      "--collation-server=utf8mb4_unicode_ci"
    ];
    # No published DB port: only containers on the dedicated bridge can connect.
    extraOptions = [
      "--network=youtarr-network"
      "--health-cmd=healthcheck.sh --connect --innodb_initialized"
      "--health-interval=10s"
      "--health-timeout=5s"
      "--health-start-period=30s"
      "--health-retries=5"
    ];
  };

  # MariaDB creates/chowns its own database directory to its in-container mysql user.
  systemd.tmpfiles.rules = [
    "d ${dataDir}        0755 ${uid} ${gid} - -"
    "d ${dataDir}/config 0700 ${uid} ${gid} - -"
    "d ${dataDir}/jobs   0755 ${uid} ${gid} - -"
    "d ${dataDir}/images 0755 ${uid} ${gid} - -"
  ];

  networking.firewall.allowedTCPPorts = [ svc.port ];
}