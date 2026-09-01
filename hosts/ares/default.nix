{ lib, inputs, ... }:

{
  imports = [

    # Partitioning configuration for boot drive
    # Only run on install
    ./disko.nix

    # Host-specific hardware setup (disk layout, initrd modules, etc.)
    ./hardware-configuration.nix

    # Grab the tweaks from nix-hardware to optimize this laptop.
    inputs.nixos-hardware.nixosModules.dell-xps-15-9510

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

    # NVIDIA Optimus: proprietary driver + PRIME offload for the RTX 3050 dGPU
    ../../system/modules/hardware/nvidia.nix

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
    ../../home/apps/nixvim/nixvim-light.nix
  ];

  # Plymouth fills up the /boot partition lol
  boot.plymouth.enable = lib.mkForce false;

  # Disable Intel Panel Self Refresh. On the XPS 15 9510 (TigerLake iGPU) PSR
  # triggers i915 "Fence expiration time out" / "reset request timed out" GPU
  # hangs that freeze the display for 10+ seconds under mixed GL load (browser,
  # Steam, Electron). This became noticeable once niri was moved onto the iGPU.
  boot.kernelParams = [ "i915.enable_psr=0" ];

  # Give the machine a unique hostname
  networking.hostName = "ares";

  system.stateVersion = "25.11";

}
