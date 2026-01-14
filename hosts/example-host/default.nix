{ lib, ... }:

{
  imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # This host is a qemu VM (could be changed to hardware.nix if running on bare metal)
    ../../system/roles/qemu-vm.nix

    # This host uses the base configuration
    #../../system/roles/base.nix
    # This host has a desktop environment and UI
    #../../system/roles/desktop.nix
    # Apply a profile that encompasses the above setup
    ../../system/profiles/minimal-desktop.nix
  ];

  # Here we could add our full HM configuration (core is automatically imported)
  #home-manager.users.gideon.imports = lib.mkAfter [
  #  ../../home/roles/workstation.nix
  #];

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
