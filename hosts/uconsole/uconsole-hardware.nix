{ config, lib, pkgs, ... }:
# This file contains configuration specific to the uConsole hardware
{
  # Enable GPS service for onboard GPS antenna
  #services.gpsd.devices = [];

  # AIO board stuff

  # GPS
  # Enable the system GPS service
  services.gpsd.enable = true;

}
