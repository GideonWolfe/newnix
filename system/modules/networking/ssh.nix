{ config, lib, pkgs, ... }:
{
  services.openssh = {
    enable = true;
    ports = [ 2736 ];
    openFirewall = true;
    settings = {
      # Never allow login as root
      PermitRootLogin = "no";
      # Disable password authentication, only allow key-based auth
      PasswordAuthentication = false;
    };
  };
  #programs.ssh.startAgent = true;
}