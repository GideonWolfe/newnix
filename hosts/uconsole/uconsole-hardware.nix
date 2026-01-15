{ config, lib, pkgs, ... }:
# This file contains configuration specific to the uConsole hardware
{
  # Enable GPS service for onboard GPS antenna

  # AIO board stuff

  # GPS
  # Enable the system GPS service
  services.gpsd.enable = true;
  services.gpsd.devices = [ "/dev/ttyS0" ]; # UART0 for GPS

  # LoRa / Meshtastic
  # Enable the meshtasticd daemon for LoRa mesh networking
  services.meshtasticd = {
    enable = false;
    gps = {
      enable = true;
      device = "/dev/ttyS0"; # Use /dev/ttyAMA0 for CM5
    };
    webserver = {
      enable = true;
      port = 443;
      openFirewall = false; # Set to true if you want remote access
    };
    # Set your LoRa region via the web interface on first boot
    # Options: US, EU_868, EU_433, CN, JP, ANZ, KR, TW, RU, IN, etc.
    loraRegion = "US";
  };

}
