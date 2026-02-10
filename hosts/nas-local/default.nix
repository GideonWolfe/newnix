{ lib, inputs, ... }:
  
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
  ];

  # Plymouth fills up the /boot partition lol
  boot.plymouth.enable = lib.mkForce false;

  # Give the machine a unique hostname
  networking.hostName = "mnemosyne";

  system.stateVersion = "25.11";

}
