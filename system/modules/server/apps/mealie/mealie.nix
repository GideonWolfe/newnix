{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.mealie = {
    image = "ghcr.io/mealie-recipes/mealie:latest";
    ports = [ "${builtins.toString config.custom.world.services.mealie.port}:9000" ];
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      BASE_URL = "https://${config.custom.world.services.mealie.domain}";
      TZ = "America/New_York";
      MAX_WORKERS = "1";
      WEB_CONCURRENCY = "1";
    };
    volumes = [
      "/data/mealie/data:/app/data"
    ];
    environmentFiles = [ config.sops.secrets."mealie/env".path ];
  };

  # Pre-create the bind-mount targets with 1000:100 ownership so docker
  # (which runs as root) doesn't create them as root on first start.
  # PUID=1000/PGID=100 above will then match the host-side ownership.
  systemd.tmpfiles.rules = [
    "d /data/mealie       0755 1000 100 - -"
    "d /data/mealie/data  0755 1000 100 - -"
  ];
}