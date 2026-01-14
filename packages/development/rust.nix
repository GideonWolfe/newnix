{ config, lib, pkgs, ... }:

{
	environment.systemPackages = [
		pkgs.rustup
		#pkgs.rustc
		#pkgs.cargo
		#pkgs.rust-analyzer
	];
}
