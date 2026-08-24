{ pkgs, lib, config, ... }:

# Obsidian Sync (headless) ----------------------------------------------------
# Upstream:  https://github.com/obsidianmd/obsidian-headless
#            https://obsidian.md/help/sync/headless
#
# Keeps a freshly synced copy of an Obsidian Sync vault in a directory on the
# tank pool (default /tank/personal/notes) by running the upstream `ob` CLI on
# mnemosyne itself. Because it writes straight to a local ZFS dataset, the
# existing "personal" sanoid snapshots (see hosts/mnemosyne/zfs/zfs-snapshots.nix)
# double as point-in-time version history for the notes -- no separate backup
# job is needed.
#
# WHY THIS MODULE IS "SLIM" ---------------------------------------------------
# `ob` splits its work into two distinct phases:
#
#   1. One-time bootstrap: `ob login` + `ob sync-setup` + `ob sync-config`.
#      This authenticates the machine and binds the local directory to the
#      remote vault. It writes auth tokens / device id / a sync config into
#      $HOME (stateDir below) -- NOT into the Nix store.
#
#   2. Ongoing sync: `ob sync --continuous`, which watches the vault and pulls
#      remote changes forever.
#
# Phase 1 is inherently interactive (Obsidian 2FA prompts for an MFA code that
# no unattended unit can answer) and only ever runs ONCE per machine. So rather
# than drag sops secrets + a bootstrap systemd unit into the repo just to run
# three commands one time, we do the bootstrap BY HAND (see "MANUAL BOOTSTRAP"
# at the bottom of this file) and let Nix own only the durable, repeatable part:
# the package, the state dir, and the always-on sync daemon.
#
# Net effect: NO secrets live in this repo. The only persistent state is the
# `ob` login under stateDir, which survives rebuilds untouched.
#
# The sync service is still fully declarative and is what actually matters
# day to day -- it starts `ob` on every boot and restarts it after network
# blips, so you never babysit a shell process.
#
# Ownership: runs as gideon:users -- same rationale as copyparty/aria2. Every
# file the sync writes is owned by the pool's primary user, so notes are
# editable locally and browsable over NFS/copyparty without fighting ZFS's
# NFSv4-ACL group-write masking.

let
  cfg = config.custom.services.obsidian-headless;

  user  = "gideon";
  group = "users";

  # --- Package: obsidian-headless ------------------------------------------
  # The upstream repo ships a prebuilt, bundled `cli.js` plus a pnpm lockfile;
  # the only native runtime dependency is `better-sqlite3`. pnpm 10 does NOT
  # run dependency build scripts on install, and `pnpm rebuild` is a no-op
  # here, so we compile the addon ourselves the way nixpkgs' own
  # obsidian-headless derivation does: `npm run build-release` inside the
  # better-sqlite3 dir, pointed at the Nix node source tree (offline, no
  # node-gyp download), then wrap cli.js behind an `ob` launcher.
  #
  # NOTE: nixpkgs gained an official `obsidian-headless` package after 26.05,
  # so once it lands in this flake's nixpkgs just drop this whole derivation
  # and use `pkgs.obsidian-headless` directly.
  nodeSources = pkgs.srcOnly pkgs.nodejs_22;

  obsidian-headless = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "obsidian-headless";
    version = "0.0.14";

    src = pkgs.fetchFromGitHub {
      owner = "obsidianmd";
      repo  = "obsidian-headless";
      tag   = finalAttrs.version;
      hash  = "sha256-ue2M9maFyvabGH9qTDOpAJS4OPwCikpAMYm/M/XRGKo=";
    };

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      # Pin the pnpm fetcher output format (required by newer nixpkgs).
      # fetcherVersion 2 is deprecated for removal in 26.11 -- migrate to 3
      # (and regenerate this hash) when bumping past 26.05.
      fetcherVersion = 2;
      hash = "sha256-N+4BOSW8uRG/7iH38By/sQtviM07yxyhr6fxdojZNv0=";
    };

    nativeBuildInputs = [
      pkgs.nodejs_22
      pkgs.pnpm          # provides the `pnpm` binary the configHook shells out to
      pkgs.pnpmConfigHook
      pkgs.python3       # node-gyp needs a Python to build better-sqlite3
      pkgs.node-gyp
      pkgs.makeWrapper
    ];

    # Compile the native better-sqlite3 addon offline against the Nix node
    # source, then strip references to that (huge) source tree from the output
    # so it isn't dragged into the runtime closure.
    buildPhase = ''
      runHook preBuild

      pushd node_modules/better-sqlite3
      npm run build-release --offline "--nodedir=${nodeSources}"
      find build -type f -exec \
        ${pkgs.removeReferencesTo}/bin/remove-references-to -t "${nodeSources}" {} \;
      rm -rf deps src   # build-only inputs, not needed at runtime
      popd

      rm -rf btime/win32-* # Windows-only birthtime binaries, never used

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/lib/obsidian-headless"
      cp -r cli.js btime node_modules package.json "$out/lib/obsidian-headless/"
      makeWrapper ${lib.getExe pkgs.nodejs_22} "$out/bin/ob" \
        --add-flags "$out/lib/obsidian-headless/cli.js"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Headless client for Obsidian Sync";
      homepage    = "https://github.com/obsidianmd/obsidian-headless";
      license     = licenses.unfree; # Obsidian is not open source
      mainProgram = "ob";
      platforms   = platforms.linux;
    };
  });

  ob = lib.getExe obsidian-headless;
in
{
  options.custom.services.obsidian-headless = {
    enable = lib.mkEnableOption "headless Obsidian Sync into a NAS directory";

    vaultDir = lib.mkOption {
      type = lib.types.str;
      default = "/tank/personal/notes";
      example = "/tank/personal/notes";
      description = ''
        Local directory the vault is synced into. On mnemosyne this lives on
        the tank pool so the existing "personal" ZFS snapshots cover it. This
        is the `--path` you pass to `ob sync-setup` during manual bootstrap.
      '';
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/obsidian-headless";
      description = ''
        HOME for the sync service. `ob` keeps its login token, device id and
        sync cursors here -- this is the state created by the one-time manual
        bootstrap and reused by the daemon forever after. Lives on local disk,
        deliberately separate from the vault directory.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Make `ob` available system-wide -- REQUIRED for the manual bootstrap and
    # handy for ad-hoc `ob sync-status` / `ob sync-config` maintenance.
    environment.systemPackages = [ obsidian-headless ];

    # Ensure the state and vault directories exist, owned by gideon:users, so
    # the manual `ob login` (run as gideon) and the daemon share one HOME.
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${user} ${group} - -"
      "d ${cfg.vaultDir} 0755 ${user} ${group} - -"
    ];

    # Continuous sync daemon -- the always-on half. It is GATED on whether the
    # one-time manual bootstrap has run yet: `ob login` writes its auth token
    # and per-vault sync state under $HOME/.config/obsidian-headless, so the
    # presence of that directory means "set up". ConditionPathExists below
    # makes systemd SKIP the unit (inactive, not failed) until it exists --
    # which keeps `pushbuild` / switch-to-configuration green pre-bootstrap.
    # Without the gate, `ob sync` exits non-zero ("vault not set up"), the
    # switch sees a failed unit, and the whole deploy reports failure. After
    # bootstrap the directory exists, the condition passes, and the daemon runs
    # on every boot -- no marker file or manual bookkeeping step required.
    #
    # NB: we deliberately use ConditionPathExists on the config dir rather than
    # ConditionDirectoryNotEmpty on stateDir, because the latter IGNORES hidden
    # entries (systemd checks it with ignore_hidden_or_backup=true) and `ob`
    # stores everything under the hidden `.config` -- so a bootstrapped stateDir
    # would still read as "empty" and the unit would never start.
    systemd.services.obsidian-headless-sync = {
      description = "Obsidian Headless: continuous vault sync";
      wantedBy    = [ "multi-user.target" ];
      after       = [ "network-online.target" ];
      wants       = [ "network-online.target" ];

      serviceConfig = {
        Type             = "simple";
        User             = user;
        Group            = group;
        WorkingDirectory = cfg.vaultDir;
        Environment      = [ "HOME=${cfg.stateDir}" ];
        ExecStart        = "${ob} sync --continuous --path ${cfg.vaultDir}";
        Restart          = "on-failure";
        RestartSec       = 30;

        # Hardening. ReadWritePaths carves the two dirs we own back out of the
        # otherwise read-only filesystem imposed by ProtectSystem = "strict".
        NoNewPrivileges  = true;
        ProtectSystem    = "strict";
        ProtectHome      = true;
        PrivateTmp       = true;
        ReadWritePaths   = [ cfg.stateDir cfg.vaultDir ];
      };

      unitConfig = {
        # Skip (don't fail) the unit until `ob login` has created its config
        # dir -- keeps deploys green before the vault is bootstrapped.
        ConditionPathExists = "${cfg.stateDir}/.config/obsidian-headless";
        # Once bootstrapped, keep retrying forever on transient failures
        # (network blips) without the start-rate limiter latching us into a
        # hard `failed` state.
        StartLimitIntervalSec = 0;
      };
    };
  };
}

# --- MANUAL BOOTSTRAP (run ONCE on mnemosyne) --------------------------------
# After the first `pushbuild mnemosyne` puts `ob` on PATH and creates the dirs,
# authenticate the machine and bind the vault. Run everything as `gideon` with
# HOME pointed at the state dir so the daemon inherits the same login:
#
#   sudo -u gideon HOME=/var/lib/obsidian-headless ob login
#       # prompts for email + password (+ 2FA code if enabled)
#
#   sudo -u gideon HOME=/var/lib/obsidian-headless ob sync-list-remote
#       # confirm the vault name/ID you want
#
#   sudo -u gideon HOME=/var/lib/obsidian-headless \
#     ob sync-setup --vault "My Vault" --path /tank/personal/notes \
#       --device-name mnemosyne
#       # add `--password <e2ee-pass>` here if the vault is end-to-end encrypted
#
#   # Pull-only so the NAS can never push local changes back and corrupt the
#   # canonical vault. Use `bidirectional` if you want to edit notes on the NAS,
#   # or `mirror-remote` for an exact one-way mirror that reverts local drift.
#   sudo -u gideon HOME=/var/lib/obsidian-headless \
#     ob sync-config --path /tank/personal/notes --mode pull-only
#
#   # Optional one-shot to verify before handing off to the daemon:
#   sudo -u gideon HOME=/var/lib/obsidian-headless ob sync --path /tank/personal/notes
#
# The very first `ob login` above already populated the state dir, so the
# daemon's gate (ConditionDirectoryNotEmpty) is now satisfied. Just start it:
#
#   sudo systemctl start obsidian-headless-sync
#   systemctl status obsidian-headless-sync
