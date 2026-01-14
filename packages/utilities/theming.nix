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
		libsForQt5.breeze-icons
		# Qt theming tools
		libsForQt5.qt5ct
		qt6Packages.qt6ct
		libsForQt5.qtcurve
		libsForQt5.qtstyleplugins
		# Additional theming tools
		spicetify-cli
	];
}
