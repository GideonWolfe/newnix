# This role can be cleanly imported into any desktop configuration to provide common desktop services.
# This means ANY system with a UI, whether it's a laptop, desktop, or VM.
{
  imports = [
    # Basic nix settings
    ../modules/system/nix.nix
    # Home manager setup
    ../modules/system/home-manager.nix
  ];
}