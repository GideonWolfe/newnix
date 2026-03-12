{ lib, ... }:
let
  mkIp = default: lib.mkOption { type = lib.types.str; inherit default; };
in
{
  options.custom.world = {
    hosts = {
      athena     = { ip = mkIp "192.168.88.201"; };
      poseidon   = {
        ip = mkIp "192.168.88.202";
        wireguard.ip = mkIp "10.0.0.1";
        wireguard.public_key = mkIp ""; # fill in after: wg pubkey < /root/wireguard/poseidon-wg0-private.key
      };
      hades      = { ip = mkIp "192.168.88.203"; };
      pixel9a    = { ip = mkIp "192.168.88.204"; };
      mnemosyne  = { ip = mkIp "192.168.88.205"; };
      access_point = { ip = mkIp "192.168.88.2"; };
      monitor    = { ip = mkIp "165.227.70.3"; };
      homeserver = { ip = mkIp "66.108.176.86"; };

      router = {
        ip = mkIp "192.168.88.1";
        subnet = lib.mkOption {
          type = lib.types.str;
          default = "192.168.88.0/24";
        };
        wireguard = {
          ip = mkIp "10.0.0.254";
          subnet = lib.mkOption {
            type = lib.types.str;
            default = "10.0.0.0/24";
            description = "The subnet Wireguard uses for its VPN network";
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 51820;
            description = "The port Wireguard listens on for incoming connections";
          };
          public_key = lib.mkOption {
            type = lib.types.str;
            default = "FHr9Cpx7fgC8qrWLJo4TmLwl9Q0g44wkFnH5P4e/z0A=";
            description = "The public key of the router's Wireguard interface";
          };
        };
      };

      proxmox = {
        vms = {
          ingress_vm = { ip = mkIp "192.168.88.100"; };
          media_vm = {
            ip = mkIp "192.168.88.101";
            downloadsDir = lib.mkOption {
              type = lib.types.str;
              default = "/data/downloads";
              description = "Base directory for media downloads shared by Sonarr, Radarr, NZBGet, etc.";
            };
          };
          app1_vm = { ip = mkIp "192.168.88.102"; };
        };
        nodes = {
          pvenet = { ip = mkIp "192.168.88.7"; };
          pve1   = { ip = mkIp "192.168.88.8"; };
          pve2   = { ip = mkIp "192.168.88.9"; };
          pve3   = { ip = mkIp "192.168.88.10"; };
        };
      };
    };

    email = {
      infra_email = {
        address = lib.mkOption {
          type = lib.types.str;
          default = "gideon@gideonwolfe.xyz";
          description = "The email currently assigned as infrastructure email";
        };
      };
    };
  };
}
