{ pkgs, lib, config, ... }:

# Karakeep - self-hosted bookmark / read-it-later / archive app.
# https://github.com/karakeep-app/karakeep
#
# Faithful port of the upstream docker-compose.yml:
#   https://github.com/karakeep-app/karakeep/blob/main/docker/docker-compose.yml
# Three containers on a dedicated docker bridge so service-name DNS works:
#   - karakeep-web      Next.js UI + API (port 3000)
#   - karakeep-chrome   Headless Chromium for full-page archive/screenshots
#   - karakeep-meili    Meilisearch index (rebuildable from sqlite)
#
# Persistent state lives under /data/karakeep on the VM's data disk:
#   data/         -> sqlite DB + uploaded assets (the precious bits)
#   meilisearch/  -> search index (regenerable, kept for convenience)
#
# Secrets (NEXTAUTH_SECRET, MEILI_MASTER_KEY) come in via sops templates
# (see ./secrets/secrets_karakeep.nix). NEXTAUTH_URL is plain config and
# lives in the static `environment` block here.

let
  svc = config.custom.world.services.karakeep;

  # Pin the image versions so an unattended `docker pull` doesn't drag in
  # a breaking upgrade. Bump deliberately, in a PR, alongside any
  # `meilisearch` major bumps (which require a re-index).
  #   https://github.com/karakeep-app/karakeep/pkgs/container/karakeep
  karakeepVersion = "0.32.0";
  chromeImage     = "gcr.io/zenika-hub/alpine-chrome:124";
  meiliImage      = "getmeili/meilisearch:v1.41.0";

  dataDir  = "/data/karakeep";
  appData  = "${dataDir}/data";
  meiliData = "${dataDir}/meilisearch";
in
{
  # Dedicated bridge network so the web container can reach `chrome` and
  # `meilisearch` by container name (matches the upstream compose file).
  systemd.services.docker-create-karakeep-network = {
    description = "Create karakeep docker bridge network";
    after       = [ "docker.service" ];
    wantedBy    = [ "multi-user.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.docker}/bin/docker network inspect karakeep-network >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create karakeep-network
    '';
  };

  systemd.services.docker-karakeep-web.after        = [ "docker-create-karakeep-network.service" ];
  systemd.services.docker-karakeep-web.requires     = [ "docker-create-karakeep-network.service" ];
  systemd.services.docker-karakeep-chrome.after     = [ "docker-create-karakeep-network.service" ];
  systemd.services.docker-karakeep-chrome.requires  = [ "docker-create-karakeep-network.service" ];
  systemd.services.docker-karakeep-meili.after      = [ "docker-create-karakeep-network.service" ];
  systemd.services.docker-karakeep-meili.requires   = [ "docker-create-karakeep-network.service" ];

  # ---- web -------------------------------------------------------------
  # The Next.js UI + API. Listens on 3000 inside the container; we publish
  # it 1:1 to the VM so internal LAN tools / browser extensions can hit it
  # while Traefik on vm-ingress fronts it for the public domain.
  virtualisation.oci-containers.containers.karakeep-web = {
    image     = "ghcr.io/karakeep-app/karakeep:${karakeepVersion}";
    autoStart = true;

    ports = [ "${builtins.toString svc.port}:3000" ];

    environment = {
      # Cross-container endpoints (resolved on the karakeep-network bridge)
      MEILI_ADDR      = "http://karakeep-meili:7700";
      BROWSER_WEB_URL = "http://karakeep-chrome:9222";

      # Public URL Karakeep uses for OAuth callbacks, share links, etc.
      # Must match the Traefik router host on vm-ingress.
      #NEXTAUTH_URL    = "${svc.protocol}://${svc.domain}";

      # DON'T change DATA_DIR — see upstream compose. If we ever want to
      # relocate state we change the bind mount below, not this var.
      DATA_DIR        = "/data";

      # Optional: uncomment + add OPENAI_API_KEY to the sops env file to
      # enable LLM auto-tagging. See:
      #   https://docs.karakeep.app/configuration/different-ai-providers
      # INFERENCE_TEXT_MODEL = "gpt-4o-mini";
    };
    environmentFiles = [ config.sops.templates."karakeep-web-env".path ];

    volumes = [
      "${appData}:/data"
    ];

    extraOptions = [
      "--network=karakeep-network"
      "--hostname=karakeep-web"
    ];
  };

  # ---- chrome ----------------------------------------------------------
  # Headless Chromium used for full-page archives + screenshots. No state,
  # no exposed port (only reachable on the karakeep-network bridge).
  virtualisation.oci-containers.containers.karakeep-chrome = {
    image     = chromeImage;
    autoStart = true;

    # Match upstream compose flags 1:1.
    cmd = [
      "--no-sandbox"
      "--disable-gpu"
      "--disable-dev-shm-usage"
      "--remote-debugging-address=0.0.0.0"
      "--remote-debugging-port=9222"
      "--hide-scrollbars"
    ];

    extraOptions = [
      "--network=karakeep-network"
      "--hostname=karakeep-chrome"
    ];
  };

  # ---- meilisearch -----------------------------------------------------
  # Search index. Regenerable from the sqlite DB, but we still persist it
  # to avoid a full rebuild every restart (large libraries take minutes).
  virtualisation.oci-containers.containers.karakeep-meili = {
    image     = meiliImage;
    autoStart = true;

    environment = {
      MEILI_NO_ANALYTICS = "true";
    };
    environmentFiles = [ config.sops.templates."karakeep-meili-env".path ];

    volumes = [
      "${meiliData}:/meili_data"
    ];

    extraOptions = [
      "--network=karakeep-network"
      "--hostname=karakeep-meili"
    ];
  };

  # Pre-create the bind-mount parent so docker doesn't auto-create it on
  # first start. Ownership is intentionally left as root:root - each
  # container manages the UID/GID inside its own mount itself:
  #
  #   * karakeep-web / -workers  s6-overlay boots as PID 1 (root) and
  #                              drops privileges to the baked-in `node`
  #                              user (UID 1000) before touching /data.
  #   * karakeep-meili           runs as the baked-in `meili` user and
  #                              chowns /meili_data on init.
  #
  # Neither image honors PUID/PGID, so trying to pre-chown these to
  # gideon:users (1000:100) would either get clobbered on next start or
  # fight meili's init. If you want host-side access without sudo, the
  # only safe directory to retag is ${appData} (matches karakeep-web's
  # node:node 1000:1000) - but the GID won't be 100, so you'd still
  # need to be in a 1000 group or use sudo.
  systemd.tmpfiles.rules = [
    "d ${dataDir}   0755 root root - -"
    "d ${appData}   0755 root root - -"
    "d ${meiliData} 0755 root root - -"
  ];
}
