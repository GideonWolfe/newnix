{ lib, inputs, ... }:

{
  imports = [

    # Host-specific hardware setup (disk layout, initrd modules, etc.)
    #./hardware-configuration.nix

    # Grab the tweaks from nix-hardware to optimize this laptop.
    inputs.nixos-hardware.nixosModules.dell.xps-15-9510

    # Boot loader configuration for EFI systems
    ../../system/modules/system/systemd-boot.nix

    # This host uses my default user configuration
    ../../users/gideon/default.nix
    # This host uses my personal secrets and accounts
    ../../users/gideon/personal.nix

    # ares has more juice than poseidon, so it gets the full desktop role
    # rather than the light-workstation profile.
    ../../system/profiles/full-workstation.nix

    # Physical machine
    ../../system/roles/hardware.nix
    # This machine mounts the NAS's NFS shares when on my LAN
    ../../system/roles/home-lan.nix

    ../../system/roles/gaming.nix

    ../../system/modules/services/terraform

    ../../system/modules/networking/wireguard/wg-home.nix

    # Host a local dashboard for easy access to services
    ../../system/modules/server/apps/homepage/homepage.nix
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
    ../../home/apps/nixvim/nixvim.nix
  ];

  # Plymouth fills up the /boot partition lol
  boot.plymouth.enable = lib.mkForce false;

  # Give the machine a unique hostname
  networking.hostName = "ares";

  system.stateVersion = "25.11";

}
