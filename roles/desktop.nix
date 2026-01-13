# This role can be cleanly imported into any desktop configuration to provide common desktop services.
# This means ANY system with a UI, whether it's a laptop, desktop, or VM.
{
  imports = [
    # Basic nix settings
    ../modules/system/nix.nix
    # Enable audio
    ../modules/system/pipewire.nix

    # Enable the boot splash and display manager
    ../modules/ui/plymouth.nix
    ../modules/ui/greeter.nix

    # Hyprland for our main window manager
    ../modules/ui/hyprland.nix
    # Other desktop glue
    ../modules/ui/xdg-portals.nix
  ];
}