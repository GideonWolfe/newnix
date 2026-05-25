{ pkgs, lib, config, ... }:

# Baikal - lightweight CalDAV + CardDAV server built on sabre/dav.
# Standalone calendar/contacts/tasks sync endpoint that speaks the
# standard protocols natively, so any client that talks vanilla CalDAV
# (Apple Reminders, Thunderbird, DAVx5, Evolution, vdirsyncer/khal,
# todoman, ...) can sync against it without app-specific integration.
#
# Upstream:        https://sabre.io/baikal/
# Container image: docker.io/ckulka/baikal (community image, 5M+ pulls)
# Source:          https://github.com/ckulka/baikal-docker
# Default port:    80 (http) - mapped to svc.port on the host
#
# Networking:
#   * The container only listens on plain HTTP. Traefik on vm-ingress
#     terminates TLS at https://${svc.domain} and proxies to this
#     container - see hosts/proxmox/vms/ingress/services/traefik/
#     services/baikal.nix.
#   * Because clients always hit baikal via the standard https/:443
#     entry on a real hostname, the ckulka/baikal-docker#300 nginx
#     port-stripping bug never fires (it only matters when the
#     published port differs from the URL's port). No nginx override
#     required - we run the stock image.
#
# Setup flow (browser):
#   1. Open https://${svc.domain}
#   2. Set the admin password + accept the SQLite DB defaults
#   3. Add users + calendars/addressbooks through the admin UI
#   4. Connect clients - for sabre/dav-based servers the canonical
#      URLs are:
#        CalDAV   https://${svc.domain}/dav.php/calendars/<user>/<cal>/
#        CardDAV  https://${svc.domain}/dav.php/addressbooks/<user>/<ab>/
#      .well-known autodiscovery (/.well-known/caldav, /carddav) also
#      works once traefik is in front.
#
# Bind mount layout (host -> container):
#   /data/baikal/config    -> /var/www/baikal/config    (baikal.yaml etc)
#   /data/baikal/Specific  -> /var/www/baikal/Specific  (SQLite DB,
#                                                       per-user data)
let
  svc = config.custom.world.services.baikal;
  dataDir = "/data/baikal";
in
{
  virtualisation.oci-containers.containers.baikal = {
    # nginx variant: half the size of apache, no startup warnings.
    # Pin to 0.10.1 (last tagged release) - the floating `nginx` tag is
    # a weekly rebuild that can quietly bring in upstream changes.
    # Available tags: https://hub.docker.com/r/ckulka/baikal/tags
    image = "ckulka/baikal:0.10.1-nginx";
    autoStart = true;

    ports = [ "${builtins.toString svc.port}:80" ];

    environment = {
      TZ = "America/New_York";
    };

    volumes = [
      # Per-user data + SQLite DB. This IS the source of truth - back up
      # with restic when promoting off the sandbox.
      "${dataDir}/Specific:/var/www/baikal/Specific"
      # baikal.yaml + system.yaml + database.yaml. Worth backing up but
      # smaller / regeneratable if lost.
      "${dataDir}/config:/var/www/baikal/config"
    ];
  };

  # Pre-create bind-mount parents so docker doesn't auto-create them on
  # first start. Ownership is intentionally root:root - the container's
  # entrypoint (/docker-entrypoint.d/40-fix-baikal-file-permissions.sh)
  # chowns these to its internal www-data user (UID 33 in debian-based
  # images) on every start, so pre-setting 1000:100 here would just get
  # clobbered. Same pattern as karakeep/dawarich.
  systemd.tmpfiles.rules = [
    "d ${dataDir}           0755 root root - -"
    "d ${dataDir}/Specific  0755 root root - -"
    "d ${dataDir}/config    0755 root root - -"
  ];
}
