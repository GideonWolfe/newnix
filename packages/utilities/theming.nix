{ config, lib, pkgs, ... }:

{
	# Utilities to support desktop level theming
	# Imported by desktop role
	environment.systemPackages = with pkgs; [
		# Icon themes
		papirus-icon-theme
		papirus-folders
		adwaita-icon-theme
		material-icons
		kdePackages.breeze-icons
		# Qt theming tools
		libsForQt5.qt5ct
		qt6Packages.qt6ct
		# qtcurve was removed from libsForQt5 in 26.05; commented out for now
		# libsForQt5.qtcurve
		libsForQt5.qtstyleplugins
		# Additional theming tools
		spicetify-cli
	];
}
