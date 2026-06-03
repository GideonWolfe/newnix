{ pkgs, lib, config, ... }:

# FreshRSS container, configured per the official docker-compose example:
#   https://hub.docker.com/r/freshrss/freshrss#docker-compose
# Secrets (ADMIN_EMAIL / ADMIN_PASSWORD / ADMIN_API_PASSWORD) are injected
# via a sops template rendered into an EnvironmentFile.
{
  virtualisation.oci-containers.containers.freshrss = {
    image = "freshrss/freshrss:latest";
    ports = [ "${builtins.toString config.custom.world.services.freshrss.port}:80" ];
    autoStart = true;
    environment = {
      TZ = "America/New_York";
      CRON_MIN = "13,43";
      #BASE_URL = "https://${config.custom.world.services.freshrss.domain}";
      # Auto-install on first run; ignored on subsequent starts.
      FRESHRSS_INSTALL = ''
        --api-enabled
        --default-user admin
        --language en
      '';
      FRESHRSS_USER = ''
        --api-password ''${ADMIN_API_PASSWORD}
        --email ''${ADMIN_EMAIL}
        --language en
        --password ''${ADMIN_PASSWORD}
        --user admin
      '';
    };
    environmentFiles = [ config.sops.templates."freshrss-env".path ];
    volumes = [
      "/data/freshrss/data:/var/www/FreshRSS/data"
      "/data/freshrss/extensions:/var/www/FreshRSS/extensions"
    ];
  };

  # Pre-create bind-mount targets owned by gideon:users (1000:100) so they
  # aren't created as root by docker on first start, matching the rest of
  # the stack.
  systemd.tmpfiles.rules = [
    "d /data/freshrss            0755 1000 100 - -"
    "d /data/freshrss/data       0755 1000 100 - -"
    "d /data/freshrss/extensions 0755 1000 100 - -"
  ];
}