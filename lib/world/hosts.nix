{ lib, ... }:
{
  options.custom.world = {
    hosts = {
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

      mnemosyne = {
        ip = lib.mkOption {
          type = lib.types.str;
          default = "192.168.0.137";
          description = "The local IP of my NAS";
        };
      };

      proxmox = {
        vms = {
          media_vm = {
            ip = lib.mkOption {
              type = lib.types.str;
              default = "192.168.0.10";
              description = "The IP address of the media VM";
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
