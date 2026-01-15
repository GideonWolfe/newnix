{ config, lib, pkgs, ... }:
# This file contains configuration specific to the uConsole hardware
{
  # Enable GPS service for onboard GPS antenna

  # AIO board stuff

  # GPS
  # Enable the system GPS service
  services.gpsd.enable = true;
  services.gpsd.devices = [ "/dev/ttyS0" ]; # UART0 for GPS

}
