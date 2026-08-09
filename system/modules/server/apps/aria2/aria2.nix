{ inputs, config, lib, ... }:

# Aria2: headless download daemon controlled over JSON-RPC. Lets you browse the
# web on a desktop (hades/poseidon) and hand off URLs/torrents/magnets to the
# NAS, which then pulls them directly over its fast wired link -- no
# download-to-desktop-then-reupload-over-wifi round trip.
#
# Drive it from a browser with the "Aria2 Explorer" extension (or AriaNg web
# UI) pointed at http://<mnemosyne>:6800/jsonrpc using the RPC token.
#
# Ownership note: the upstream module runs the daemon as the dedicated `aria2`
# user (good for isolation). By default it also creates the download dir as
# `aria2:aria2`, which is awkward over NFS because access then depends on
# gideon's *supplementary* group membership (fragile with NFS AUTH_SYS). We
# instead make the download dir group `users` + setgid, so downloads land as
# `aria2:users`. gideon's *primary* group is `users`, and primary-group creds
# are always honored over NFS -- so gideon (and copyparty) can read/manage the
# files with no supplementary-group juggling on either host.
let
  svc = config.custom.world.services.aria2;
  cfg = config.custom.services.aria2;
in
{
  imports = [
    # Sops secret (RPC token) consumed via LoadCredential below
    ./secrets/secrets_aria2.nix
  ];

  options.custom.services.aria2.dataDir = lib.mkOption {
    type = lib.types.str;
    default = "/var/lib/aria2/Downloads";
    example = "/tank/downloads";
    description = ''
      Directory aria2 downloads into. On the NAS point this at a gideon-owned
      location on the tank pool so downloads are immediately browsable via
      copyparty and the rest of the stack.
    '';
  };

  config = {
    services.aria2 = {
      enable = true;
      # Token pulled from the sops secret (never in the nix store).
      rpcSecretFile = config.sops.secrets."aria2/rpc_token".path;
      # Open the RPC port + BitTorrent listen range on the LAN.
      openPorts = true;
      # 0002 so group members (gideon via primary group `users`) can
      # modify/delete the downloaded files.
      serviceUMask = "0002";
      # setgid on the dir so new files inherit the dir's group.
      downloadDirPermission = "2775";

      settings = {
        dir = cfg.dataDir;
        rpc-listen-port = svc.port;
        # Allow RPC access from other LAN hosts (desktop browsers), not just
        # localhost.
        rpc-listen-all = true;
        # Resume/continue partial downloads instead of restarting.
        continue = true;
        # Saturate the wired link with parallel connections per download.
        max-connection-per-server = 8;
        split = 8;
        min-split-size = "10M";
      };
    };

    # Own the download dir as group `users` (setgid) so downloads inherit that
    # group and gideon can manage them via his *primary* group -- robust over
    # NFS, unlike supplementary-group membership. Priority 99 sorts after the
    # upstream module's rule so this wins.
    systemd.tmpfiles.settings."99-aria2-downloads".${cfg.dataDir}.d = {
      user = "aria2";
      group = "users";
      mode = "2775";
    };
  };
}
