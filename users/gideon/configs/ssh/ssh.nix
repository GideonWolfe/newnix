{ pkgs, lib, config, osConfig, ... }:

{
  # handle symlinking my public key to the SSH folder
  home.file.gideon_ssh_sk_pub = {
    enable = true;
    source = ./gideon_ssh_sk.pub;
    target = "${config.home.homeDirectory}/.ssh/gideon_ssh_sk.pub";
  };
  home.file.gideon_backup_ssh_sk_pub = {
    enable = true;
    source = ./gideon_backup_ssh_sk.pub;
    target = "${config.home.homeDirectory}/.ssh/gideon_backup_ssh_sk.pub";
  };

  programs.ssh = {

    enable = true;
    enableDefaultConfig = false;

    #addKeysToAgent = "yes";
    # Should prevent being prompted for yubikey every 5 seconds with nixos-anywhere

    # Uses upstream ssh_config(5) directive names (HostName, User, Port, ...).
    settings = {

      "*" = {
        ForwardAgent = false;
        ForwardX11 = false;
      };

      # GitHub SSH Auth
      github = {
        HostName = "github.com";
        IdentityFile = [
          "${config.home.homeDirectory}/.ssh/gideon_ssh_sk"
          "${config.home.homeDirectory}/.ssh/gideon_backup_ssh_sk"
          #"/home/gideon/nix/configs/users/gideon/configs/ssh/keys/github-nixos-tester"
        ];
        User = "git";
      };

      # Example of main server
      homeserver = {
        HostName = "66.108.176.86";
        Port = 2736;
        IdentityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
        User = "overseer";
      };
      # Jumping through server to desktop
      desktop = {
        HostName = "192.168.0.103";
        Port = 2736;
        ProxyJump = "homeserver";
      };


      # Home Network Devices
      router = {
        HostName = "${osConfig.custom.world.hosts.router.ip}";
      };
      access_point = {
        HostName = "${osConfig.custom.world.hosts.access_point.ip}";
      };

      # NAS (LAN)
      mnemosyne = {
        HostName = "${osConfig.custom.world.hosts.mnemosyne.ip}";
        Port = 2736;
        IdentityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
      };

      # Laptop (LAN)
      ares = {
        HostName = "${osConfig.custom.world.hosts.ares.ip}";
        Port = 2736;
        IdentityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
      };

      # Physical Proxmox Hosts
      pvenet = {
        HostName = "${osConfig.custom.world.hosts.proxmox.nodes.pvenet.ip}";
        User = "root";
      };
      pve1 = {
        HostName = "${osConfig.custom.world.hosts.proxmox.nodes.pve1.ip}";
        User = "root";
      };
      pve2 = {
        HostName = "${osConfig.custom.world.hosts.proxmox.nodes.pve2.ip}";
        User = "root";
      };
      pve3 = {
        HostName = "${osConfig.custom.world.hosts.proxmox.nodes.pve3.ip}";
        User = "root";
      };

      # Proxmox VMs
      vm-media = {
        HostName = "${osConfig.custom.world.hosts.proxmox.vms.vm_media.ip}";
        Port = 2736;
        IdentityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
      };
      vm-ingress = {
        HostName = "${osConfig.custom.world.hosts.proxmox.vms.vm_ingress.ip}";
        Port = 2736;
        IdentityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
      };
      vm-app1 = {
        HostName = "${osConfig.custom.world.hosts.proxmox.vms.vm_app1.ip}";
        Port = 2736;
        IdentityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
      };
      vm-app2 = {
        HostName = "${osConfig.custom.world.hosts.proxmox.vms.vm_app2.ip}";
        Port = 2736;
        IdentityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
      };
      vm-test = {
        HostName = "${osConfig.custom.world.hosts.proxmox.vms.vm_test.ip}";
        Port = 2736;
        IdentityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
      };
      vm-ai = {
        HostName = "${osConfig.custom.world.hosts.proxmox.vms.vm_ai.ip}";
        Port = 2736;
        IdentityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
      };

    };

  };

}
