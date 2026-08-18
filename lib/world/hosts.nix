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
        wireguard.public_key = mkIp "RKr0FtPL+VnOal/gy8kkwHx+IJbzimoEgZ5KO8X18XE=";
      };
      hades      = { ip = mkIp "192.168.88.203"; };
      ares       = {
        ip = mkIp "192.168.88.207";
        wireguard.ip = mkIp "10.0.0.4";
        wireguard.public_key = mkIp "BV3zT/7rLhuzfHCnhwYtcF9ovjfSs8pit+I0ISly7C8=";
      };
      pixel9a    = {
        ip = mkIp "192.168.88.204";
        wireguard.ip = mkIp "10.0.0.2";
        wireguard.public_key = mkIp "yVjPDm5jjI9rqTG9m1zapHl6gzqxbXBfJaq1IlO4Z14=";
      };
      retroidpocket6    = {
        ip = mkIp "192.168.88.206";
        wireguard.ip = mkIp "10.0.0.3";
        wireguard.public_key = mkIp "N5/g+wB3XnvU0MeYNZ2sq+GHDEzJ5kASz+WZbcY/mG4=";
      };
      mnemosyne  = { ip = mkIp "192.168.88.205"; };
      # Offsite backup NAS (UGREEN DXP2800). Not yet stood up; IP is a
      # placeholder to be finalized once the offsite network is provisioned.
      soteria    = { ip = mkIp "10.10.10.10"; };
      access_point = { ip = mkIp "192.168.88.2"; };
      monitor    = { ip = mkIp "165.227.70.3"; };
      homeserver = { ip = mkIp "66.108.176.86"; };

      # SLZB-06MU Zigbee coordinator. Trusted infra on the main LAN (NOT the
      # IoT VLAN); Home Assistant reaches it over ser2net (tcp 6638).
      slzb06 = { ip = mkIp "192.168.88.168"; };

      # IoT VLAN devices (subnet defined in networks.nix). Home Assistant is
      # multi-homed here via a second NIC to reach IoT gear directly.
      iot = {
        gateway = { ip = mkIp "192.168.20.1"; };
        homeassistant = { ip = mkIp "192.168.20.2"; };
      };

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
          vm_ingress = { ip = mkIp "192.168.88.100"; };
          vm_app1 = { ip = mkIp "192.168.88.101"; };
          vm_app2 = { ip = mkIp "192.168.88.104"; };
          vm_media = {
            ip = mkIp "192.168.88.102";
            downloadsDir = lib.mkOption {
              type = lib.types.str;
              default = "/data/downloads/nzbget";
              description = "Base directory for media downloads shared by Sonarr, Radarr, NZBGet, etc.";
            };
            musicDownloadsDir = lib.mkOption {
              type = lib.types.str;
              default = "/data/downloads/soulseek";
              description = "Base directory for music downloads shared by SoulSync/Slskd.";
            };
          };
          vm_test = { ip = mkIp "192.168.88.103"; };
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
