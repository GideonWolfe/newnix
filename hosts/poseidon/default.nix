{ lib, ... }:
  
{
  imports = [
    
    # Host-specific hardware setup (disk layout, initrd modules, etc.)
    ./hardware-configuration.nix
    # Boot loader configuration for EFI systems
    ../../system/modules/system/systemd-boot.nix

    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # Apply a system profile that matches this host
    ../../system/profiles/minimal-desktop.nix
    
    # Augment with roles as needed
    ../../system/roles/hardware.nix
    
    # Or any other arbitrary module we are testing
    #../../system/modules/services/radio/hamclock/hamclock.nix

    # Radio packages
    ../../packages/science/radio/radio.nix
  ];

  # Here we could add our full HM configuration (core is automatically imported)
  home-manager.users.gideon.imports = [
    # The desktop with desktop environment and apps
    ../../home/roles/desktop.nix
    ../../home/roles/extra.nix
    # Host-specific UI scaling settings
    ./ui.nix
    # Gideon's personal accounts
    #../../users/gideon/personal.nix
    # Or any other arbitrary HM config we are testing
    ../../home/sessions/niri/niri.nix
  ];

  # Give the machine a unique hostname
  networking.hostName = "poseidon";

  system.stateVersion = "25.11";

}
