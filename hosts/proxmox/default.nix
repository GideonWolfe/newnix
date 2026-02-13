{ lib, ... }:
  
{
  imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # This host is a proxmox-vm
    ../../system/roles/vm-proxmox.nix

    # Let's montior the VM
    ../../system/roles/monitoring.nix

    # Apply a system profile that matches this host
    ../../system/profiles/minimal.nix

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
  networking.interfaces.enp1s0.useDHCP = false;


  # Automatically format and mount the data disk
  # Possibly move into VM specific config,
  # i think every VM will get one anyways?
  fileSystems."/data" = {
    device = "/dev/sdb";
    fsType = "ext4";
    autoFormat = true;
    options = [ "defaults" ];
  };

  system.stateVersion = "25.11";

}
