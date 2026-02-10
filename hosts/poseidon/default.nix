{ lib, inputs, ... }:
  
{
  imports = [
    
    # Host-specific hardware setup (disk layout, initrd modules, etc.)
    ./hardware-configuration.nix

    # Also grab the tweaks from nix-hardware to optimize this system
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t490

    # Boot loader configuration for EFI systems
    ../../system/modules/system/systemd-boot.nix

    # This host uses my default user configuration
    ../../users/gideon/default.nix
    # This host uses my personal secrets and accounts
    ../../users/gideon/personal.nix

    # Apply a system profile that matches this host
    # This will enable the necessary roles and packages
    ../../system/profiles/light-workstation.nix
    
    # Augment with extra roles as needed
    ../../system/roles/hardware.nix
    
    # Or any other arbitrary module we are testing
    #../../system/modules/services/radio/hamclock/hamclock.nix
    ../../system/roles/home-machine.nix # This machine lives at home, so it should have access to the NAS and NFS shares
  ];

  # Here we could add our full HM configuration (core is automatically imported)
  home-manager.users.gideon.imports = [
    # The desktop with desktop environment and apps
    ../../home/roles/desktop.nix
    ../../home/roles/extra.nix
    # Host-specific UI scaling settings
    ./ui.nix
    # Or any other arbitrary HM config we are testing
    ../../home/sessions/niri/niri.nix
    # NixVim configuration (belongs in HM, not system modules)
    ../../home/apps/nixvim/nixvim-light.nix
  ];

  # Plymouth fills up the /boot partition lol
  boot.plymouth.enable = lib.mkForce false;

  # Give the machine a unique hostname
  networking.hostName = "poseidon";

  system.stateVersion = "25.11";

}
