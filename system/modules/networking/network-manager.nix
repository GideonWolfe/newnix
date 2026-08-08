{ lib, ... }:
{
	# Enable Network Manager
	networking.networkmanager.enable = true;
	# Use the card's permanent hardware MAC so DHCP reservations stay stable.
	networking.networkmanager.wifi.macAddress = "permanent";
	networking.networkmanager.wifi.scanRandMacAddress = false;
	# Enable tray applet
	programs.nm-applet.enable = true;
	# Enable DHCP by default
	networking.useDHCP = lib.mkDefault true;
}