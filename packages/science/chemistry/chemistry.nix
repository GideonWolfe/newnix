{ config, lib, pkgs, ... }:
let
  periodic-table-cli = pkgs.callPackage ../../custom/periodic-table-cli.nix {};
in
{
	environment.systemPackages = [


		#############
		# CHEMISTRY #
		#############
		pkgs.kdePackages.kalzium # Periodic table
		pkgs.nucleus # Periodic table
		pkgs.pymol # molecular graphics tool
		pkgs.openmolcas # quantum chemistry software
		pkgs.chemtool # draw chemical structures
		pkgs.avogadro2 # molecular editor enable when space
		pkgs.avogadrolibs # molecular editor enable when space
		pkgs.molsketch # 2D molecular editor
		pkgs.gromacs # molecular dynamics
		periodic-table-cli # interactive periodic table TUI

        # brewing
        pkgs.brewtarget # beer recipe creation tool

	];

    services.flatpak.packages = [
        "io.github.ksharindam.chemcanvas"
    ];
}
