{ lib, ... }:
  
{
  imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # Let's montior the VM
    ../../system/roles/monitoring.nix

    # Apply a system profile that matches this host
    ../../system/profiles/proxmox-app-vm.nix

    # Let this VM mount the NAS NFS shares
    ../../system/modules/networking/mnemosyne-nfs.nix
  ];

  # Here we could add our full HM configuration (core is automatically imported)
  home-manager.users.gideon.imports = [
    # Only the basic configs
    ../../home/roles/core.nix
  ];

  # Point at the router
  networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "192.168.0.1" ];
  # Don't let the router automatically assign an IP
  #networking.interfaces.enp1s0.useDHCP = false;


  system.stateVersion = "25.11";

  # # Host-specific VM settings
  # virtualisation = {
  #   # Allocate reasonable resources for testing
  #   memorySize = 4096; # 4GB RAM for desktop environment
  #   cores = 4;
  #   # Enable graphics for GUI testing
  #   graphics = true;
  #   # Disk size for the VM
  #   diskSize = 26384; # 16GB for desktop apps
  # };

}
