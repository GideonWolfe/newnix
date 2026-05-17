# Niri input configuration (keyboard, mouse, touchpad, focus behavior).
# Merged into `programs.niri.settings.input` by the home-manager module system.
{ ... }:
{
  programs.niri.settings.input = {
    keyboard.xkb.layout = "us";

    # Make the mouse follow our focused window
    warp-mouse-to-focus = {
      enable = false; # interfering with scrolling on Workspaces
      mode = "center-xy";
    };

    # Mouse movement settings
    mouse = {
      accel-speed = 1.0;
      scroll-factor = 1;
    };

    # Touchpad settings
    touchpad = {
      tap = true;
      # Disable touchpad while typing, could interfere with games
      dwt = true;
      natural-scroll = true;
      click-method = "clickfinger";
    };

    # Make the focus follow the mouse
    focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "0%";
    };

    # workspace-auto-back-and-forth = true;
  };
}
