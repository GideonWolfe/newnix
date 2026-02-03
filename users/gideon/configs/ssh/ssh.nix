{ pkgs, lib, config, osConfig, ... }:

{
  # handle symlinking my public key to the SSH folder
  home.file.gideon_ssh_sk_pub = {
    enable = true;
    source = ./gideon_ssh_sk.pub;
    target = "${config.home.homeDirectory}/.ssh/gideon_ssh_sk.pub";
  };

  programs.ssh = {

    enable = true;
    enableDefaultConfig = false;

    #addKeysToAgent = "yes";
    # Should prevent being prompted for yubikey every 5 seconds with nixos-anywhere

    matchBlocks = {

      "*" = {
        forwardAgent = false;
        forwardX11 = false;
      };

      # GitHub SSH Auth
      github = {
        hostname = "github.com";
        identityFile = [
          "${config.home.homeDirectory}/.ssh/gideon_ssh_sk"
          #"/home/gideon/nix/configs/users/gideon/configs/ssh/keys/github-nixos-tester"
        ];
        user = "git";
      };

      # Example of main server
      homeserver = {
        hostname = "66.108.176.86";
        port = 2736;
        identityFile = [ "${config.home.homeDirectory}/.ssh/gideon_ssh_sk" ];
        user = "overseer";
      };
      # Jumping through server to desktop
      desktop = {
        hostname = "192.168.0.103";
        port = 2736;
        proxyJump = "homeserver";
      };
    };

  };

}
