# This role is used for any system where we are gaming
{
  imports = [

    ###########
    # Modules #
    ###########
    # Steam, of course    
    ../modules/services/steam.nix

    ############
    # Packages #
    ############
    # Gaming packages
    ../packages/gaming/gaming.nix 
  ];
}