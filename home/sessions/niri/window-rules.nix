# Niri window rules. Stylix colors are pulled in so commented examples that
# reference base0X / named palette entries can be uncommented without
# additional plumbing.
{ config, ... }:
with config.lib.stylix.colors.withHashtag;
{
  programs.niri.settings.window-rules = [
    # Special rule for Kando menus
    {
      matches = [ { title = "Kando Menu"; } ];
      open-floating = true;
      focus-ring.enable = true;
      border.enable = false;
      shadow.enable = false;
    }

    # Browser Picture-in-Picture. Firefox uses "Picture-in-Picture" while
    # Chromium/Vivaldi/Brave use "Picture in Picture"; the [- ] character
    # class covers both. Pin to the top-right with a small inset so it
    # doesn't collide with window decorations or a top bar.
    {
      matches = [ { title = "^Picture[- ]in[- ]Picture$"; } ];
      open-floating = true;
      default-floating-position = {
        relative-to = "top-right";
        x = 32;
        y = 32;
      };
    }

    # Privacy: hide password managers and other secret-bearing windows from
    # screen recorders and `wlr-screencopy` clients (e.g. OBS, grim). The
    # built-in niri screenshot tool is unaffected by `block-out-from`, so
    # screenshots still work normally.
    #
    # Using `screen-capture` (the strictest setting) blocks both the
    # ScreenCast portal *and* `wlr-screencopy`, so window contents cannot
    # leak via screenshot-preview overlays during a live stream either.
    {
      matches = [
        { app-id = "^(org\\.keepassxc\\.KeePassXC|keepassxc)$"; }
        { app-id = "^(bitwarden|Bitwarden)$"; }
        { app-id = "^1[Pp]assword$"; }
      ];
      block-out-from = "screen-capture";
    }

    # {
    #   matches = [ { app-id = "^signal$"; } ];
    #   border.active.color = "${blue}";
    # }
  ];
}
