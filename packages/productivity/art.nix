{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [

    # All Art packages are grouped together, since realistically they would always be installed together

    pkgs.eyedropper # advanced color picking utility (GNOME)

    ############
    # MODELING #
    ############
    pkgs.blockbench # Low-poly 3d modeler

    ##########
    # IMAGES #
    ##########
    pkgs.letterpress # create ascii art from images
    pkgs.paleta # extract dominant colors from an image
    pkgs.pigment # extract dominant colors from an image

    ###########
    # FASHION #
    ###########
    pkgs.valentina # Open source sewing pattern drafting software

    ############
    # PAINTING #
    ############
    pkgs.inkscape-with-extensions
    pkgs.inkscape-extensions.inkstitch
    pkgs.krita
    pkgs.drawing # lightweight drawing app

  ];
}
