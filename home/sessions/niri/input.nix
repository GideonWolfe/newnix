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
      dwt = false;
      natural-scroll = true;
      click-method = "clickfinger";
    };

    # Make the focus follow the mouse
    focus-follows-mouse = {
      enable = true;
      max-scroll-amount = "0%";
    };

    # When you press Mod+N while already on workspace N, cycle back to the
    # workspace you came from. niri tracks the actual workspace (not its
    # index), so reordering workspaces does not break this.
    workspace-auto-back-and-forth = true;
  };

  # Cursor visibility. `cursor` is a top-level niri setting, but it's
  # input-adjacent in spirit so it lives here next to mouse/touchpad config.
  programs.niri.settings.cursor = {
    # Hide while you're typing so the pointer doesn't sit on top of the
    # caret in your terminal/editor.
    hide-when-typing = true;
    # Also fade the cursor out after 5s of inactivity (helps with video /
    # long-form reading).
    hide-after-inactive-ms = 5000;
  };
}
