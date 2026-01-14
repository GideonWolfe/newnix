{ config, lib, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
		# nix tools
		# couple things to access dconf settings and convert them to nix
		dconf2nix
		dconf-editor
		nix-search-tv # fuzzy search nix packages
		television # general purpose Fuzzy Finder, should be moved
		nix-tree # browse dependencies of nix store
		nix-output-monitor # adds visuals to build outputs
		nixos-anywhere # install Nix on fresh machines
		deploy-rs # just to make the binary available, can still use nix run and the flake URL
	];
}
