{ lib, ... }:

{
  imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # This host is a qemu VM (could be changed to hardware.nix if running on bare metal)
    ../../system/roles/vm-qemu.nix

    # Apply a system profile that matches this host
    ../../system/profiles/minimal-desktop.nix
    #../../system/profiles/minimal.nix
    
    # Or any other arbitrary module we are testing
  ];

  # Here we could add our full HM configuration (core is automatically imported)
  home-manager.users.gideon.imports = [
    # The desktop with desktop environment and apps
    ../../home/roles/desktop.nix
    # Gideon's personal accounts
    #../../users/gideon/personal.nix
    # Or any other arbitrary HM config we are testing
  ];

  # Give the machine a unique hostname
  networking.hostName = "atlas";

  system.stateVersion = "25.11";

  # Host-specific VM settings
  virtualisation = {
    # Allocate reasonable resources for testing
    memorySize = 4096; # 4GB RAM for desktop environment
    cores = 4;
    # Enable graphics for GUI testing
    graphics = true;
    # Disk size for the VM
    diskSize = 16384; # 16GB for desktop apps
  };

}
