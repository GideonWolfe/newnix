{ pkgs, lib, config, ... }:

# Obsidian Sync (headless) ----------------------------------------------------
# Upstream:  https://github.com/obsidianmd/obsidian-headless
#            https://obsidian.md/help/sync/headless
#
# Provides the `ob` CLI from the upstream `obsidian-headless` npm package and
# runs continuous sync of a single Obsidian vault into a directory on the NAS
# (mounted via /nas/tank). Login + sync-setup are performed once at activation
# from sops-managed secrets; subsequent restarts just resume continuous sync.
#
# Required sops secrets (see ./secrets/secrets_obsidian-headless.nix):
#   obsidian/email           - Obsidian account email
#   obsidian/password        - Obsidian account password
#   obsidian/vault_name      - Remote vault name (or ID) to sync
#   obsidian/e2ee_password   - End-to-end encryption password for the vault
#                              (only needed for e2ee vaults; leave empty file
#                              for standard-encrypted vaults)
let
  user  = "obsidian-sync";
  group = "obsidian-sync";

  # Where the vault lives on disk. Lives on the NAS so it survives host churn
  # and is accessible to other clients.
  vaultDir = "/nas/tank/notes/obsidian-vault";

  # Home dir for the service user. `ob` keeps its state
  # (auth tokens, device id, sync cursors) in $HOME/.config/obsidian-headless.
  stateDir = "/var/lib/obsidian-headless";

  # --- Package: obsidian-headless ------------------------------------------
  # Build the upstream CLI from GitHub. There are no GitHub releases yet, so
  # we pin a commit.
  #
  # First time you build this, both hashes will be `lib.fakeHash` — `nix build`
  # will fail and print the correct values. Paste them in and rebuild.
  obsidian-headless = pkgs.buildNpmPackage {
    pname = "obsidian-headless";
    version = "unstable-2026-02-27";

    src = pkgs.fetchFromGitHub {
      owner = "obsidianmd";
      repo  = "obsidian-headless";
      # TODO: bump to a current commit when updating.
      rev   = "master";
      hash  = lib.fakeHash;
    };

    # `nix build` will tell you the correct value; paste it in here.
    npmDepsHash = lib.fakeHash;

    # The package only ships a CLI (cli.js) — no build step needed.
    dontNpmBuild = true;

    # package.json declares `bin: { "ob": "cli.js" }` so npm install wires up
    # the `ob` symlink in $out/bin automatically.
    meta = with lib; {
      description = "Headless client for Obsidian Sync";
      homepage    = "https://github.com/obsidianmd/obsidian-headless";
      license     = licenses.unfree; # Obsidian is not open source
      mainProgram = "ob";
    };
  };

  # Path to the `ob` binary inside the derivation, for use in ExecStart.
  ob = "${obsidian-headless}/bin/ob";
in
{
  ###########################################################################
  # Make `ob` available system-wide (handy for ad-hoc maintenance).
  ###########################################################################
  environment.systemPackages = [ obsidian-headless ];

  ###########################################################################
  # Dedicated service user.
  ###########################################################################
  users.users.${user} = {
    isSystemUser = true;
    inherit group;
    home = stateDir;
    createHome = true;
    description = "Obsidian headless sync service";
  };
  users.groups.${group} = { };

  ###########################################################################
  # Grant the service user read access to its sops secrets. The secrets
  # themselves are declared in ./secrets/secrets_obsidian-headless.nix; here
  # we just set ownership so the service can read them at activation time.
  ###########################################################################
  sops.secrets."obsidian/email".owner          = user;
  sops.secrets."obsidian/password".owner       = user;
  sops.secrets."obsidian/vault_name".owner     = user;
  sops.secrets."obsidian/e2ee_password".owner  = user;

  ###########################################################################
  # Ensure the state and vault directories exist with the right ownership.
  # (The NAS share is mounted via x-systemd.automount, so the parent path
  # will exist; we just create our subdirectory and chown it.)
  ###########################################################################
  systemd.tmpfiles.rules = [
    "d ${stateDir}            0750 ${user} ${group} - -"
    "d ${stateDir}/.config    0750 ${user} ${group} - -"
    "d ${vaultDir}            0750 ${user} ${group} - -"
  ];

  ###########################################################################
  # Bootstrap: log in to Obsidian Sync and bind the local directory to the
  # remote vault. Runs once — guarded by a marker file in the state dir.
  ###########################################################################
  systemd.services.obsidian-headless-bootstrap = {
    description = "Obsidian Headless: bootstrap login + sync-setup";
    wantedBy    = [ "multi-user.target" ];
    before      = [ "obsidian-headless-sync.service" ];

    # Ensure the NAS is mounted before we touch the vault directory.
    unitConfig.RequiresMountsFor = [ "/nas/tank" ];
    after        = [ "network-online.target" "nas-tank.automount" ];
    wants        = [ "network-online.target" ];

    serviceConfig = {
      Type             = "oneshot";
      RemainAfterExit  = true;
      User             = user;
      Group            = group;
      WorkingDirectory = stateDir;
      Environment      = [ "HOME=${stateDir}" ];
    };

    # Read secrets at runtime (NOT into the nix store). Idempotent: skip if
    # the marker file already exists.
    script = ''
      set -euo pipefail

      marker="${stateDir}/.bootstrapped"
      if [ -f "$marker" ]; then
        echo "Already bootstrapped; nothing to do."
        exit 0
      fi

      email=$(cat ${config.sops.secrets."obsidian/email".path})
      password=$(cat ${config.sops.secrets."obsidian/password".path})
      vault=$(cat ${config.sops.secrets."obsidian/vault_name".path})
      e2ee=$(cat ${config.sops.secrets."obsidian/e2ee_password".path} || echo "")

      echo "Logging in to Obsidian Sync as $email..."
      ${ob} login --email "$email" --password "$password"

      echo "Linking ${vaultDir} to remote vault \"$vault\"..."
      if [ -n "$e2ee" ]; then
        ${ob} sync-setup \
          --vault "$vault" \
          --path "${vaultDir}" \
          --password "$e2ee" \
          --device-name "$(${pkgs.nettools}/bin/hostname)"
      else
        ${ob} sync-setup \
          --vault "$vault" \
          --path "${vaultDir}" \
          --device-name "$(${pkgs.nettools}/bin/hostname)"
      fi

      touch "$marker"
      echo "Bootstrap complete."
    '';
  };

  ###########################################################################
  # Continuous sync. Restarts on failure (e.g. transient network blips).
  ###########################################################################
  systemd.services.obsidian-headless-sync = {
    description = "Obsidian Headless: continuous vault sync";
    wantedBy    = [ "multi-user.target" ];
    after       = [
      "network-online.target"
      "nas-tank.automount"
      "obsidian-headless-bootstrap.service"
    ];
    requires    = [ "obsidian-headless-bootstrap.service" ];
    wants       = [ "network-online.target" ];

    unitConfig.RequiresMountsFor = [ "/nas/tank" ];

    serviceConfig = {
      Type              = "simple";
      User              = user;
      Group             = group;
      WorkingDirectory  = vaultDir;
      Environment       = [ "HOME=${stateDir}" ];
      ExecStart         = "${ob} sync --continuous --path ${vaultDir}";
      Restart           = "on-failure";
      RestartSec        = 15;

      # Hardening
      NoNewPrivileges   = true;
      ProtectSystem     = "strict";
      ProtectHome       = true;
      PrivateTmp        = true;
      ReadWritePaths    = [ stateDir vaultDir ];
    };
  };
}
