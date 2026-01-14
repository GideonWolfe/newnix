# This role can be cleanly imported into any configuration that is running in a DigitalOcean VM
{ inputs, modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/digital-ocean-config.nix"
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.useDHCP = lib.mkForce false;

  # Cloud Init settings
  services.cloud-init = {
    enable = true;
    network.enable = true;
    settings = {
      #networking.enable = true;
      datasource_list = [ "ConfigDrive" "Digitalocean" ];
      datasource.ConfigDrive = { };
      datasource.Digitalocean = { };
      # Based on https://github.com/canonical/cloud-init/blob/main/config/cloud.cfg.tmpl
      cloud_init_modules = [
        "seed_random"
        "bootcmd"
        "write_files"
        "growpart"
        "resizefs"
        #"set_hostname" # these should be handled from within nix
        #"update_hostname"
        #"set_password"
      ];
      cloud_config_modules = [
        #"ssh-import-id" # also should be handled by nix
        "keyboard"
        # doesn't work with nixos
        #"locale"
        "runcmd"
        "disable_ec2_metadata"
      ];
      ## The modules that run in the 'final' stage
      cloud_final_modules = [
        "write_files_deferred"
        # I don't use these, so not needed?
        #"puppet" 
        #"chef"
        #"ansible"
        "mcollective"
        "salt_minion"
        "reset_rmc"
        # install dotty agent fails
        #"scripts_vendor"
        "scripts_per_once"
        "scripts_per_boot"
        # /var/lib/cloud/scripts/per-instance/machine_id.sh has broken shebang
        #"scripts_per_instance"
        "scripts_user"
        "ssh_authkey_fingerprints"
        "keys_to_console"
        "install_hotplug"
        "phone_home"
        "final_message"
      ];
    };
  };

  # Disk settings
  disko.devices = {
    disk.disk1 = {
      device = lib.mkDefault "/dev/vda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [ "defaults" ];
            };
          };
        };
      };
    };
  };
}