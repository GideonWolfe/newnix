{ pkgs, lib, config, ... }:

# Forgejo - self-hosted git forge (Gitea fork). Barebones SQLite setup,
# no Traefik route yet, LAN-only on vm-test.
#
# Upstream:  https://forgejo.org
# NixOS:     services.forgejo (nixpkgs `nixos/modules/services/misc/forgejo.nix`)
#
# Setup flow (browser):
#   1. Open http://${svc.ip}:${svc.port}
#   2. Forgejo skips the install wizard (settings.security.INSTALL_LOCK
#      is forced to true by the NixOS module since config is declarative).
#      Create the first admin user from the CLI instead:
#         sudo -u forgejo forgejo --config /var/lib/forgejo/custom/conf/app.ini \
#              admin user create --admin --username gideon --email gideon@... \
#              --random-password --must-change-password
#   3. Add an SSH key to your account; clone with
#         git clone ssh://git@${svc.ip}:${svc.sshPort}/<user>/<repo>.git
#
# Storage split (the whole point of the layout):
#   LOCAL  /data/forgejo                  -> stateDir
#       SQLite DB, secrets, generated app.ini, logs, dumps. Hot, small,
#       benefits from local SSD. Restic-backup separately later.
#
#   NAS    /nas/tank/services/forgejo/repositories  -> repositoryRoot
#          /nas/tank/services/forgejo/lfs           -> lfs.contentDir
#       Bulk git data + LFS objects. If the VM dies, repos survive
#       intact on the NAS and can be cloned as bare git directly or
#       rehydrated into a fresh Forgejo.
#
# UID/GID pinning:
#   The NixOS module creates a dedicated `forgejo` system user with an
#   auto-allocated UID. Auto-allocation is fine when everything lives on
#   one filesystem; it's a problem when half of state lives on NFS,
#   because a UID shift across nixpkgs upgrades would orphan every repo
#   on the NAS. We pin to 2042:2042 - high enough to avoid system UIDs
#   (<1000) and out of the way of gideon (1000) - and mirror those exact
#   numbers when chown-ing the NAS dirs (see footer comment).

let
  svc = config.custom.world.services.forgejo;

  # See "UID/GID pinning" note above. Bump only if you also re-chown
  # the NAS-side tree to match.
  forgejoUid = 2042;
  forgejoGid = 2042;

  # Local hot state (sqlite, conf, secrets, log, dump output).
  stateDir = "/data/forgejo";

  # Bulk repo + LFS data on the NAS. Pre-provision before first boot
  # (see footer of this file).
  reposDir = "/nas/tank/services/forgejo/repositories";
  lfsDir   = "/nas/tank/services/forgejo/lfs";
in
{
  # Pin the daemon's identity. Merges with the upstream module's
  # users.users.forgejo / users.groups.forgejo declarations.
  users.users.forgejo.uid  = forgejoUid;
  users.groups.forgejo.gid = forgejoGid;

  services.forgejo = {
    enable = true;

    # Track latest stable, not LTS - we want the same release line the
    # docker `:11` tag would have given us. Bump deliberately when the
    # nixpkgs pin advances a major.
    package = pkgs.forgejo;

    # Local state directory. The upstream module's tmpfiles rules will
    # create + chown this; we just make sure /data is mounted first via
    # systemd ordering below.
    stateDir = stateDir;

    # The bulk-on-NAS split. Forgejo bind-equivalent: it just writes
    # bare git into this path, no metadata mixed in.
    repositoryRoot = reposDir;

    # LFS objects are bulk too - park them next to the repos so the
    # whole "things you'd hate to lose" set lives on one tree.
    lfs = {
      enable     = true;
      contentDir = lfsDir;
    };

    # SQLite is enough for personal scale. Promote to postgres only if
    # we ever want to share this with other people.
    database.type = "sqlite3";

    # Built-in periodic dump (metadata + sqlite; NOT the repos - those
    # are already on the NAS). Lands in ${stateDir}/dump - cheap to
    # restic-snapshot later if we want a second copy off-host.
    dump = {
      enable   = true;
      interval = "daily";
      type     = "tar.zst";
    };

    settings = {
      server = {
        # DOMAIN feeds ROOT_URL defaults and shows up in clone URLs.
        # LAN-only via raw IP for now; flip to a hostname once Traefik
        # fronts this.
        DOMAIN    = svc.ip;
        HTTP_PORT = svc.port;
        ROOT_URL  = "${svc.protocol}://${svc.ip}:${toString svc.port}/";

        # Use Forgejo's built-in SSH server instead of the system-sshd
        # passthrough. Passthrough would mean forgejo manages the
        # `forgejo` user's authorized_keys and clients hit system sshd
        # on 2736 - workable but couples this module to the host's
        # ssh port. Built-in is a self-contained daemon on its own
        # port (svc.sshPort).
        START_SSH_SERVER = true;
        SSH_LISTEN_PORT  = svc.sshPort;
        SSH_PORT         = svc.sshPort;   # what the UI prints in clone URLs
      };

      service = {
        # Open during initial setup so we can create the admin via UI
        # if needed. Flip to true after the admin account exists.
        DISABLE_REGISTRATION = false;
      };

      session = {
        # Fine on LAN HTTP. Flip when Traefik terminates TLS.
        COOKIE_SECURE = false;
      };
    };
  };

  # Don't start the daemon until the NAS automount is up - otherwise
  # the upstream module's tmpfiles rules can race and create the repos
  # dir on the local FS, which then *shadows* the NFS mount when it
  # eventually comes up. Same pattern as obsidian-headless.
  systemd.services.forgejo = {
    unitConfig.RequiresMountsFor = [ "/nas/tank" ];
    after = [ "network-online.target" "nas-tank.automount" ];
    wants = [ "network-online.target" ];
  };

  # /data parent only. The upstream module's tmpfiles rules manage
  # stateDir, repositoryRoot, and lfs.contentDir ownership/perms.
  systemd.tmpfiles.rules = [
    "d /data 0755 1000 100 - -"
  ];

  # LAN firewall openings: web UI + built-in SSH server.
  networking.firewall.allowedTCPPorts = [ svc.port svc.sshPort ];

  # ---- one-time NAS provisioning on mnemosyne ------------------------
  # Run once before first nixos-rebuild of this VM (or any time after a
  # forgejoUid/Gid bump):
  #
  #   sudo mkdir -p /tank/services/forgejo/{repositories,lfs}
  #   sudo chown -R 2042:2042 /tank/services/forgejo
  #   sudo chmod  0750         /tank/services/forgejo/repositories
  #   sudo chmod  0750         /tank/services/forgejo/lfs
  #
  # NFS export: the dataset's sharenfs property should NOT use
  # all_squash. We want UID 2042 to pass through unchanged so the
  # forgejo daemon's view of ownership matches what's on disk. Default
  # `rw,sync` is fine. Verify with `zfs get sharenfs tank/services`.
}
