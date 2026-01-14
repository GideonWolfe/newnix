{ lib, ... }:

{
  imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # Apply a system profile that matches this host
    #../../system/profiles/minimal-desktop.nix
    ../../system/profiles/minimal.nix

    # uConsole specific configs
    ./initial-setup.nix
    ./hardware-configuration.nix
  ];

  # Here we could add our full HM configuration (core is automatically imported)
  #home-manager.users.gideon.imports = [
    # The desktop with desktop environment and apps
    #../../home/roles/desktop.nix
    # Gideon's personal accounts
    #../../users/gideon/personal.nix
    # Or any other arbitrary HM config we are testing
  #];

  # Give the machine a unique hostname
  networking.hostName = "uconsole";


  # Uconsole specific settings

  # Enable cached raspberry pi packages
  nix.settings = {
    substituters = [
      "https://cache.nixos.org/"
      "https://nixos-raspberrypi.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };



  system.stateVersion = "25.11";
}
