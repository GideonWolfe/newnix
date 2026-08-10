{ inputs, config, lib, ... }:

# Copyparty: a lightweight, single-binary file server with a browser UI plus
# webdav/ftp/smb access. Handy for LAN hosts that don't have the NFS share
# mounted -- they can just grab/drop files over HTTP.
#
# Upstream NixOS module + overlay come from the copyparty flake input:
#   https://github.com/9001/copyparty#nixos-module
#
# The service runs as gideon:users (uid 1000 / gid 100) to match the
# PUID/PGID convention used by the rest of the stack, so files it serves and
# writes on the gideon-owned `tank` pool never drift in ownership. Despite
# running as gideon, the upstream module sandboxes the process with
# TemporaryFileSystem="/:ro" + BindPaths, so it can only ever see the volume
# path below (plus the nix store) -- not gideon's home, SSH keys, etc.
let
  svc = config.custom.world.services.copyparty;
  cfg = config.custom.services.copyparty;
in
{
  imports = [
    inputs.copyparty.nixosModules.default
    # Sops secret (copyadmin password) consumed by the account below
    ./secrets/secrets_copyparty.nix
  ];

  options.custom.services.copyparty.dataDir = lib.mkOption {
    type = lib.types.str;
    default = "/srv/copyparty";
    example = "/tank/copyparty";
    description = ''
      Filesystem path copyparty serves as its root volume. On the NAS this
      should point at a gideon-owned location on the tank pool. The upstream
      module creates it (owned by the service user) only if it doesn't already
      exist, so pre-existing dataset ownership is left untouched.
    '';
  };

  config = {
    # Expose the copyparty package to the module via its overlay.
    nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

    services.copyparty = {
      enable = true;
      # Run as gideon:users so served/written files match the pool owner and
      # the rest of the PUID=1000/PGID=100 stack.
      user = "gideon";
      group = "users";

      # Login account. Password is read at runtime from the sops secret by
      # copyparty's preStart (running as the service user).
      accounts.copyadmin.passwordFile =
        config.sops.secrets."copyparty/copyadmin_password".path;

      # [global] section; see `copyparty --help`.
      settings = {
        i = "0.0.0.0";
        p = svc.port;
        # Announce over mDNS/SSDP so it shows up in LAN file managers.
        z = true;
        # Index files so search, dedup, and upload-undo work.
        e2dsa = true;
        e2ts = true;
      };

      volumes = {
        # Webroot -> dataDir. Anyone on the LAN can browse/download; only
        # copyadmin (authenticated) can upload/move/delete.
        "/" = {
          path = cfg.dataDir;
          access = {
            # copyparty perms are per-letter: r=read/browse, w=write/upload,
            # m=move/rename, d=delete. `rw` alone allows upload (copy/paste)
            # but NOT move or delete -- grant rwmd for full management.
            rwmd = [ "copyadmin" ];
            # Uncomment to let anyone on the LAN read + upload anonymously:
            # rw = [ "*" ];
          };
          flags = {
            e2d = true;
          };
        };
      };
    };

    # Open the copyparty HTTP port on the LAN.
    networking.firewall.allowedTCPPorts = [ svc.port ];
  };
}
