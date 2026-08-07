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

  # Install terminfo for all terminals so ncurses apps (htop, less, vim…)
  # work when SSHing in from clients that set exotic TERM values like
  # `xterm-kitty` or `alacritty`, which servers wouldn't otherwise know.
  environment.enableAllTerminfo = true;

  #programs.ssh.startAgent = true;
}