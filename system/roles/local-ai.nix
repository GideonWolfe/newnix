# This role is used for any system where we are gaming
{
  imports = [

    ###########
    # Modules #
    ###########
    # Install and run models locally
    ../modules/services/ai/localai.nix

    ############
    # Packages #
    ############
    # Local AI packages
    # disabling so we can test without the large downloads
    #../../packages/ai/ai-local.nix
  ];
}