# This role is used for any system where we are gaming
{
  imports = [

    ###########
    # Modules #
    ###########
    ../modules/services/ai/localai.nix # Install and run models locally
    ../modules/services/ai/clawdbot.nix # Clawdbot chatbot

    ############
    # Packages #
    ############
    # Local AI packages
    ../../packages/ai/ai-local.nix
  ];
}