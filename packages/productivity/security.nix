{ config, lib, pkgs, inputs, ... }:
{
  environment.systemPackages = [


    pkgs.concessio # GTK app to understand/convert file permissions

    ############
    # Security #
    ############
    pkgs.keepassxc
    pkgs.seahorse
    pkgs.bitwarden-desktop # connects to vaultwarden
    pkgs.authenticator # GNOME 2FA client
    

    ########################
    # Signing / Encrypting #
    ########################
    pkgs.lock # perform arbitrary encrypt/decrypt/signing with PGP keys
    pkgs.gpg-tui # manage GnuPG through the terminal
    #pkgs.kdePackages.kgpg # GUI for GPG # #BUG: this was autostarting
    pkgs.kdePackages.kleopatra # general certificate/encryption suite


  ];
}
