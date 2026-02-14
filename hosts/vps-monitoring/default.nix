{ lib, ... }:

{
  imports = [
    # This host uses my default user configuration
    ../../users/gideon/default.nix

    # This host is a DO VM
    ../../system/roles/vm-digitalocean.nix

    # Apply a system profile that matches this host
    ../../system/profiles/minimal.nix

    # Monitoring server stack
    ../../system/modules/server/monitoring/monitoring.nix
  ];

  # Here we could add our full HM configuration (core is automatically imported)
  #home-manager.users.gideon.imports = [
  # The desktop with desktop environment and apps
  #../../home/roles/desktop.nix
  # Gideon's personal accounts
  #../../users/gideon/personal.nix
  # Or any other arbitrary HM config we are testing
  #../../home/sessions/niri/niri.nix
  #];

  # Give the machine a unique hostname
  networking.hostName = "argus";

  system.stateVersion = "25.11";

}
