{ config, lib, pkgs, ... }:

{
	#environment.systemPackages = [
	#	pkgs.python311Packages.pandas
	#	pkgs.python311Packages.biopandas
	#	pkgs.python311Packages.geopandas
	#	pkgs.python311Packages.pyyaml
	#	pkgs.python311Packages.beautifulsoup4
	#];

	environment.systemPackages = [
		(pkgs.python3.withPackages (pythonPkgs: [
			pythonPkgs.pyyaml
			pythonPkgs.pandas
			pythonPkgs.biopandas
			pythonPkgs.geopandas
			pythonPkgs.beautifulsoup4
		]))
	];

}
