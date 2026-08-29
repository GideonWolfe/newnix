{ lib, ... }:
{
  # This file is for defining real-world network details.
  # Eventually I want this to be the source of truth,
  # and push settings to a router via terraform
  options.custom.world.networks = {
    home = {
      gateway = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.88.1";
          description = "The IP address of the home network gateway/router";
        };
      };
    };

    # Isolated IoT VLAN for untrusted WiFi smart-home devices. Devices reach
    # the internet but are firewalled off the main LAN; Home Assistant is
    # multi-homed onto this subnet to discover/control them.
    iot = {
      vlan_id = lib.mkOption {
        type = lib.types.int;
        default = 20;
        description = "802.1Q VLAN tag for the IoT network";
      };
      subnet = lib.mkOption {
        type = lib.types.str;
        default = "192.168.20.0/24";
        description = "The IoT VLAN subnet in CIDR notation";
      };
      gateway = lib.mkOption {
        type = lib.types.str;
        default = "192.168.20.1";
        description = "The router's gateway IP on the IoT VLAN";
      };
      dhcp = {
        start = lib.mkOption {
          type = lib.types.str;
          default = "192.168.20.100";
          description = "First address of the IoT DHCP pool";
        };
        end = lib.mkOption {
          type = lib.types.str;
          default = "192.168.20.200";
          description = "Last address of the IoT DHCP pool";
        };
      };
      dns = lib.mkOption {
        type = lib.types.str;
        default = "192.168.88.1";
        description = "DNS server handed to IoT DHCP clients (the router)";
      };
    };

    # Offsite backup site (where soteria + the remote PBS instance live).
    # soteria is the WireGuard gateway onto this LAN, so the home Proxmox
    # cluster reaches the remote PBS by routing through the tunnel into this
    # subnet (see hosts/soteria/setup.md, Phase 9). This subnet MUST NOT
    # overlap the home LAN (192.168.88.0/24) or the WG subnet (10.0.0.0/24).
    offsite = {
      subnet = lib.mkOption {
        type = lib.types.str;
        default = "10.20.0.0/24";
        description = "The offsite backup LAN subnet in CIDR notation";
      };
      gateway = lib.mkOption {
        type = lib.types.str;
        default = "10.20.0.1";
        description = "The remote router's gateway IP on the offsite LAN";
      };
    };
  };
}
