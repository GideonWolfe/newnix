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
    ./configuration.nix
  ];

  # Here we could add our full HM configuration (core is automatically imported)
  #home-manager.users.gideon.imports = [
    # The desktop with desktop environment and apps
    #../../home/roles/desktop.nix
    # Gideon's personal accounts
    #../../users/gideon/personal.nix
    # Or any other arbitrary HM config we are testing
    #./uconsole-hyprland-monitors.nix
  #];

  # Give the machine a unique hostname
  networking.hostName = "uconsole";

  system.stateVersion = "25.11";
}
