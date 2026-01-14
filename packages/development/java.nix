{ config, lib, pkgs, ... }:

{
	environment.systemPackages = [
		pkgs.jdk
	];
}
