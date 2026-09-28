{ pkgs, ... }:
{
	# Enable CUPS daemon
	services.printing = {
		enable = true;
		# Filters needed to convert jobs into a format the printer accepts.
		# Without these an IPP Everywhere job can be "accepted" then dropped.
		drivers = [
			pkgs.ghostscript # PostScript/PDF interpreter
			pkgs.cups-filters # PWG/URF raster + PDF filters used by driverless printing
		];
	};

	# The HL-L2460DW is a driverless IPP Everywhere / AirPrint printer.
	# mDNS discovery lets CUPS negotiate the correct document format.
	# services.avahi = {
	# 	enable = true;
	# 	nssmdns4 = true;
	# 	openFirewall = true;
	# };

	environment.systemPackages = with pkgs; [
		system-config-printer # GUI for printer configuration
	];
}
