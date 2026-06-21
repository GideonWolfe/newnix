{ config, lib, pkgs, ... }:

let
  asciiMol = pkgs.python312Packages.callPackage ../custom/asciiMol.nix { };
  plascad = pkgs.callPackage ../../custom/plascad.nix { };
  proteinview = pkgs.callPackage ../../custom/proteinview.nix { };
  #ugene = pkgs.callPackage ../custom/ugene.nix { }; # BUG: failing build
in {
  environment.systemPackages = [

    ###########
    # BIOLOGY #
    ###########
    pkgs.jmol # Java Molecular viewer
    pkgs.seaview # DNA alignment and phylogeny gui
    pkgs.gatk # lots of biology utilities
    #asciiMol
    # TODO won't build
    #plascad
    #ugene
    proteinview

  ];

    services.flatpak.packages = [
        "io.github.pemsley.coot"
    ];
}
