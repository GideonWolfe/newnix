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

    # {
    #   matches = [ { title = "^Picture in Picture$"; } ];
    #   open-floating = true;
    #   default-floating-position = { relative-to = "top-right"; x = -32; y = 32; };
    # }

    # {
    #   matches = [ { app-id = "^signal$"; } ];
    #   border.active.color = "${blue}";
    # }
  ];
}
