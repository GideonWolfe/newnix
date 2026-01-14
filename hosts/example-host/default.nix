{
  imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # This host is a qemu VM
    ../../roles/qemu-vm.nix

    # This host uses the base configuration
    #../../roles/base.nix
    # This host has a desktop environment and UI
    #../../roles/desktop.nix
    # Apply a profile that encompasseses the above setup
    ../../profiles/minimal-desktop.nix
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
