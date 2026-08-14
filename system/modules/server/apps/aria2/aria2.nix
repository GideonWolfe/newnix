{ inputs, config, lib, ... }:

# Aria2: headless download daemon controlled over JSON-RPC. Lets you browse the
# web on a desktop (hades/poseidon) and hand off URLs/torrents/magnets to the
# NAS, which then pulls them directly over its fast wired link -- no
# download-to-desktop-then-reupload-over-wifi round trip.
#
# Drive it from a browser with the "Aria2 Explorer" extension (or AriaNg web
# UI) pointed at http://<mnemosyne>:6800/jsonrpc using the RPC token.
#
# Ownership: for a single-user NAS the simplest, headache-free model is to run
# the daemon as gideon:users -- exactly like copyparty. Every file (and nested
# torrent dir) aria2 creates is then owned by gideon:users, so gideon and the
# rest of the PUID=1000/PGID=100 stack can always read/move/delete them,
# locally or over NFS, without leaning on group-write bits that ZFS's NFSv4
# ACLs routinely mask (the source of the "permission denied" on mv/rm). Trade-
# off: less daemon isolation, but this matches how copyparty -- a LAN-facing
# file server -- is already run.
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
      # 0002 so files land group-writable (group `users`) -- lets copyparty and
      # any other PGID=100 tooling manage them too.
      serviceUMask = "0002";
      # setgid on the dir so new files/subdirs inherit group `users`.
      downloadDirPermission = "2775";

      settings = {
        dir = cfg.dataDir;
        # Keep aria2's own writable state (session + generated conf) in a
        # dedicated StateDirectory we own as gideon, NOT the upstream
        # /var/lib/aria2 (which the upstream module still creates as
        # aria2:aria2 -- gideon can't write there, breaking preStart).
        save-session = "/var/lib/aria2-state/aria2.session";
        conf-path = "/var/lib/aria2-state/aria2.conf";
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
        # Many "generate a download link" sites 403 aria2's default UA, so
        # masquerade as a browser. `referer = "*"` reuses each download's own
        # URL as its referer, clearing referer-check 403s too.
        user-agent = "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0";
        referer = "*";

        # --- BitTorrent ---
        # DHT + PEX are on by default; LPD is not. Enable every peer-discovery
        # mechanism so magnets aren't stuck relying on a single source.
        bt-enable-lpd = true;
        # Magnets/torrents with dead or missing trackers otherwise sit at 0
        # peers forever (DHT alone can be slow/unreliable). Seed a list of
        # reliable public trackers that get merged into every torrent.
        bt-tracker = lib.concatStringsSep "," [
          "udp://tracker.opentrackr.org:1337/announce"
          "udp://open.tracker.cl:1337/announce"
          "udp://open.demonii.com:1337/announce"
          "udp://tracker.openbittorrent.com:6969/announce"
          "udp://exodus.desync.com:6969/announce"
          "udp://tracker.torrent.eu.org:451/announce"
          "udp://explodie.org:6969/announce"
          "udp://tracker.dler.org:6969/announce"
          "udp://opentracker.i2p.rocks:6969/announce"
          "udp://tracker1.bt.moack.co.kr:80/announce"
        ];
      };
    };

    # Run the daemon as gideon:users (mirrors copyparty) so downloads are owned
    # by the pool's primary user -- no cross-user directory-write juggling.
    # StateDirectory gives us a gideon-owned /var/lib/aria2-state that systemd
    # (re)creates with the right ownership on every start, sidestepping the
    # upstream aria2:aria2 /var/lib/aria2 dir entirely.
    systemd.services.aria2.serviceConfig = {
      User = lib.mkForce "gideon";
      Group = lib.mkForce "users";
      StateDirectory = "aria2-state";
      StateDirectoryMode = "0770";
    };

    # The upstream `openPorts` only opens UDP 6881-6999 (DHT / UDP trackers)
    # and TCP for the RPC port -- it never opens the *TCP* BitTorrent
    # peer-listen range, so peers can't connect inbound. Open it so we're
    # reachable and actually pick up seeders.
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 6881;
        to = 6999;
      }
    ];

    # Own the download dir as gideon:users (setgid) so downloads land with the
    # right owner and copyparty/other PGID=100 tooling can manage them too.
    # Priority 99 sorts after the upstream module's rule so this wins.
    systemd.tmpfiles.settings."99-aria2".${cfg.dataDir}.d = {
      user = "gideon";
      group = "users";
      mode = "2775";
    };
  };
}
