{ lib, inputs, pkgs, config, ... }:
  
{
  imports = [
    # Partitioning configuration for boot drive
    # Only run on install
    ./disko.nix

    # Boot loader configuration for EFI systems
    ../../system/modules/system/systemd-boot.nix

    # This host uses my default user configuration
    ../../users/gideon/default.nix
    # This host uses my personal secrets and accounts
    #../../users/gideon/personal.nix

    # Apply a system profile that matches this host
    # This will enable the necessary roles and packages
    ../../system/profiles/light-workstation.nix
    
    # Augment with extra roles as needed
    ../../system/roles/hardware.nix # This is a local system with physical access


    #############
    # NAS Stuff #
    #############
    # CPU modules and stuff for NAS hardware
    ../../system/modules/hardware/ugreen-nas.nix # This is the UGREEN NAS box, so it needs the hardware tweaks for that
    # HDD monitoring with smartd and scrutiny
    ../../system/roles/hdds.nix 

    #####################################################################
    # ZFS / tank-dependent services (FIRST DEPLOY: keep commented)      #
    #                                                                   #
    # The tank pool and its datasets do not exist yet on soteria. Do    #
    # the initial deploy with the block below commented out, create the #
    # pool + datasets by hand (mirror mnemosyne's tank layout), then    #
    # uncomment and redeploy to bring up ZFS, NFS and the file services.#
    #####################################################################
    # Services and tools to create and manage ZFS pools
    #./zfs/zfs.nix
    # Allow our datasets to be shared over NFS
    #./nfs/nfs.nix

    # Copyparty lightweight file server for LAN hosts without the NFS mount
    #../../system/modules/server/apps/copyparty

  ];

  # Here we could add our full HM configuration (core is automatically imported)
  home-manager.users.gideon.imports = [
    # The desktop with desktop environment and apps
    ../../home/roles/desktop.nix
    #../../home/roles/extra.nix
    # Or any other arbitrary HM config we are testing
    ../../home/sessions/niri/niri.nix
    # NixVim configuration
    ../../home/apps/nixvim/nixvim-light.nix
    # Host-specific UI overrides (always-on panel: no idle/lock/suspend)
    ./ui.nix
  ];

  # Plymouth fills up the /boot partition lol
  boot.plymouth.enable = lib.mkForce false;

  #####################################################################
  # ZFS / tank-dependent service settings (FIRST DEPLOY: commented)   #
  # Uncomment together with the imports above once the tank pool and  #
  # its datasets have been created.                                   #
  #####################################################################
  # Directory that copyparty serves as its root volume.
  # On the NAS this should point at a gideon-owned location on the tank pool.
  #custom.services.copyparty.dataDir = "/tank";

  # Give the machine a unique hostname
  networking.hostName = "soteria";

  system.stateVersion = "25.11";

}
