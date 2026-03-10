{ lib, ... }:
{
  options.custom.world = {
    hosts = {
      
      athena = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.88.201";
          description = "IP of Athena on the LAN";
        };
      };
      poseidon = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.88.202";
          description = "IP of Poseidon on the LAN";
        };
      };
      hades = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.88.203";
          description = "IP of Hades on the LAN";
        };
      };
      pixel9a = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.88.204";
          description = "IP of Pixel 9a on the LAN";
        };
      };

      mnemosyne = {
        ip = lib.mkOption {
          type = lib.types.str;
          #default = "192.168.0.137";
          default = "192.168.88.205";
          description = "The local IP of my NAS";
        };
      };

      router = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.88.1";
          description = "IP of the router on the LAN";
        };
        wireguard = {
          port = lib.mkOption {
            type = lib.types.port;
            default = 51820;
            description = "The port Wireguard listens on for incoming connections";
          };
          public_key = lib.mkOption {
            type = lib.types.str;
            default = "FHr9Cpx7fgC8qrWLJo4TmLwl9Q0g44wkFnH5P4e/z0A=";
            description = "The public key of the router's Wireguard interface, used for remote connections";
          };
        };
      };

      
      # Monitoring server, where all metrics and logs from across my infra are sent
      monitor = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "165.227.70.3";
          description = "The IP of the monitoring server used for remote installation and updates";
        };
      };

      # Whatever machine is hosting my media stack
      # Usually a Proxmox VM, but could be a physical server
      media = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.0.10";
          description = "The IP of the media server/VM";
        };

        downloadsDir = lib.mkOption {
          type = lib.types.str;
          default = "/data/downloads";
          description = "Base directory for media downloads shared by Sonarr, Radarr, NZBGet, etc.";
        };
      };

      homeserver = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "66.108.176.86";
          description = "The IP of my homeserver";
        };
      };


      proxmox = {
        vms = {
          ingress_vm = {
            ip = lib.mkOption {
              type = lib.types.str;
              default = "192.168.88.100";
              description = "The IP address of the ingress VM";
            };
          };
          media_vm = {
            ip = lib.mkOption {
              type = lib.types.str;
              default = "192.168.88.101";
              description = "The IP address of the media VM";
            };
          };
          app1_vm = {
            ip = lib.mkOption {
              type = lib.types.str;
              default = "192.168.88.102";
              description = "The IP address of the app1 VM";
            };
          };
        };
        nodes = {
          pvenet = {
            ip = lib.mkOption {
              type = lib.types.str;
              default = "192.168.88.7";
              description = "The IP address of PVE network node";
            };
          };
          pve1 = {
            ip = lib.mkOption {
              type = lib.types.str;
              #default = "192.168.0.223";
              default = "192.168.88.8";
              description = "The IP address of PVE1 proxmox node";
            };
          };
          pve2 = {
            ip = lib.mkOption {
              type = lib.types.str;
              #default = "192.168.0.204"; #TODO replace
              default = "192.168.88.9";
              description = "The IP address of PVE2 proxmox node";
            };
          };
          pve3 = {
            ip = lib.mkOption {
              type = lib.types.str;
              #default = "192.168.0.225"; #TODO replace
              default = "192.168.88.10";
              description = "The IP address of PVE3 proxmox node";
            };
          };
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
