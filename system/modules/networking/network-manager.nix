{ lib, ... }:
{
	# Enable Network Manager
	networking.networkmanager.enable = true;
	# Enable tray applet
	programs.nm-applet.enable = true;
	# Enable DHCP by default
	networking.useDHCP = lib.mkDefault true;
}