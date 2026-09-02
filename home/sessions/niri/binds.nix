# Niri keybindings. One entry per chord, in the direct/readable form supported
# by niri-flake (see https://github.com/sodiboo/niri-flake/blob/main/docs.md
# under `programs.niri.settings.binds`).
{ ... }:
{
  programs.niri.settings.binds = {

    # ----- Apps / session ---------------------------------------------------

    # Spawn Terminal
    "Mod+Return".action.spawn = "kitty";
    # Close focused window
    "Mod+Shift+Q".action.close-window = [ ];
    # App launcher
    "Mod+D".action.spawn = "dms ipc call spotlight toggle";
    # Quick exit
    "Mod+Shift+E".action.quit = [ ];
    # On-demand hotkey overlay. We `skip-at-startup`, so this is the only
    # way to bring it up.
    "Mod+Shift+Slash".action.show-hotkey-overlay = [ ];

    # ----- Window state toggles --------------------------------------------

    "Mod+Shift+F".action.fullscreen-window = [ ];
    "Mod+F".action.maximize-column = [ ];
    "Mod+V".action.toggle-window-floating = [ ];
    "Mod+R".action.switch-preset-column-width = [ ];
    "Mod+Shift+R".action.reset-window-height = [ ];
    "Mod+C".action.center-column = [ ];
    # Shrink the focused column width by 10%
    "Mod+Minus".action.set-column-width = "-10%";
    # Expand the focused column width by 10%
    "Mod+Equal".action.set-column-width = "+10%";
    "Mod+Shift+Minus".action.set-window-height = "-10%";
    "Mod+Shift+Equal".action.set-window-height = "+10%";

    # ----- Focus navigation -------------------------------------------------

    # Vim-style focus navigation
    "Mod+H".action.focus-column-or-monitor-left = [ ];
    "Mod+L".action.focus-column-or-monitor-right = [ ];
    "Mod+J".action.focus-window-or-workspace-down = [ ];
    "Mod+K".action.focus-window-or-workspace-up = [ ];

    # Arrow-key focus navigation (mirrors Hyprland)
    "Mod+Left".action.focus-column-or-monitor-left = [ ];
    "Mod+Right".action.focus-column-or-monitor-right = [ ];
    "Mod+Down".action.focus-window-or-workspace-down = [ ];
    "Mod+Up".action.focus-window-or-workspace-up = [ ];

    # ----- Window/column movement ------------------------------------------

    # Vim-style movement of windows/columns
    "Mod+Shift+H".action.move-column-left-or-to-monitor-left = [ ];
    "Mod+Shift+L".action.move-column-right-or-to-monitor-right = [ ];
    "Mod+Shift+J".action.move-window-down-or-to-workspace-down = [ ];
    "Mod+Shift+K".action.move-window-up-or-to-workspace-up = [ ];

    # Arrow-key movement of windows/columns
    "Mod+Shift+Left".action.move-column-left-or-to-monitor-left = [ ];
    "Mod+Shift+Right".action.move-column-right-or-to-monitor-right = [ ];
    "Mod+Shift+Down".action.move-window-down-or-to-workspace-down = [ ];
    "Mod+Shift+Up".action.move-window-up-or-to-workspace-up = [ ];

    # ----- Scroll wheel navigation -----------------------------------------

    # Scroll between columns/monitors or move columns when holding mod (and ctrl)
    "Mod+WheelScrollDown" = {
      action.focus-column-or-monitor-right = [ ];
      cooldown-ms = 150;
    };
    "Mod+WheelScrollUp" = {
      action.focus-column-or-monitor-left = [ ];
      cooldown-ms = 150;
    };
    "Mod+Ctrl+WheelScrollDown" = {
      action.move-column-right-or-to-monitor-right = [ ];
      cooldown-ms = 150;
    };
    "Mod+Ctrl+WheelScrollUp" = {
      action.move-column-left-or-to-monitor-left = [ ];
      cooldown-ms = 150;
    };

    # ----- Workspaces -------------------------------------------------------

    # Workspace focus (1–10)
    "Mod+1".action.focus-workspace = 1;
    "Mod+2".action.focus-workspace = 2;
    "Mod+3".action.focus-workspace = 3;
    "Mod+4".action.focus-workspace = 4;
    "Mod+5".action.focus-workspace = 5;
    "Mod+6".action.focus-workspace = 6;
    "Mod+7".action.focus-workspace = 7;
    "Mod+8".action.focus-workspace = 8;
    "Mod+9".action.focus-workspace = 9;
    "Mod+0".action.focus-workspace = 10;

    # Send window to workspace (silent) mirrors Hyprland movetoworkspacesilent
    "Mod+Shift+1".action.move-window-to-workspace = 1;
    "Mod+Shift+2".action.move-window-to-workspace = 2;
    "Mod+Shift+3".action.move-window-to-workspace = 3;
    "Mod+Shift+4".action.move-window-to-workspace = 4;
    "Mod+Shift+5".action.move-window-to-workspace = 5;
    "Mod+Shift+6".action.move-window-to-workspace = 6;
    "Mod+Shift+7".action.move-window-to-workspace = 7;
    "Mod+Shift+8".action.move-window-to-workspace = 8;
    "Mod+Shift+9".action.move-window-to-workspace = 9;
    "Mod+Shift+0".action.move-window-to-workspace = 10;

    # ----- Multi-monitor ---------------------------------------------------

    # Monitor focus/move for multi-monitor parity with Hyprland.
    # Use spatial left/right (not previous/next) so these match the vim
    # Mod+Shift+H/L binds; previous/next follow niri's monitor enumeration
    # order, which doesn't track the physical left-to-right layout.
    "Mod+Comma".action.focus-monitor-left = [ ];
    "Mod+Period".action.focus-monitor-right = [ ];
    "Mod+Shift+Comma".action.move-window-to-monitor-left = [ ];
    "Mod+Shift+Period".action.move-window-to-monitor-right = [ ];

    # ----- Columns / tabs / overview ---------------------------------------

    "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
    "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

    # Toggle tabbed/stack display for current column. 
    "Mod+T".action.toggle-column-tabbed-display = [ ];

    # Quick overview / workspace switcher
    "Mod+Tab".action.toggle-overview = [ ];

    # ----- Media keys -------------------------------------------------------

    # Multimedia shims (match Hyprland behavior); allow while locked
    "XF86AudioRaiseVolume" = {
      action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
      allow-when-locked = true;
    };
    "XF86AudioLowerVolume" = {
      action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
      allow-when-locked = true;
    };
    "XF86AudioMute" = {
      action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      allow-when-locked = true;
    };
    "XF86AudioMicMute" = {
      action.spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      allow-when-locked = true;
    };
    "XF86AudioNext" = {
      action.spawn = [ "playerctl" "--player" "playerctld" "next" ];
      allow-when-locked = true;
    };
    "XF86AudioPrev" = {
      action.spawn = [ "playerctl" "--player" "playerctld" "previous" ];
      allow-when-locked = true;
    };
    "XF86AudioPlay" = {
      action.spawn = [ "playerctl" "--player" "playerctld" "play-pause" ];
      allow-when-locked = true;
    };

    # ----- Screenshots ------------------------------------------------------

    # Niri ships its own interactive screenshot UI (region picker + editor),
    # writing to `programs.niri.settings.screenshot-path`. This replaces the
    # hyprshot + swappy pipeline; one less dependency and the picker is
    # aware of niri-specific surfaces (e.g. layer-shell, blocked-out windows).
    "Print".action.screenshot = [ ];              # interactive selection UI
    "Ctrl+Print".action.screenshot-screen = [ ];  # full focused output
    "Alt+Print".action.screenshot-window = [ ];   # just the focused window

    # ----- Mouse side buttons ----------------------------------------------

    # Redragon AATROX M811 PRO side buttons. keyd remaps the mouse's raw keys
    # (see system/modules/hardware/keyd.nix). XKB then translates them to the
    # keysyms below, which is what niri matches on. These were read from `wev`,
    # not guessed - XKB maps them inconsistently.
    "XF86Tools".action.focus-column-left = [ ];    # button 1 (f13): focus left
    "XF86Launch5".action.focus-column-right = [ ]; # button 2 (f14): focus right
    "F19".action.fullscreen-window = [ ];          # button 7 (f19): toggle fullscreen
    "F24".action.close-window = [ ];               # button 8 (f24): close window
    "XF86Launch6".action.toggle-overview = [ ];    # button 3 (f15): overview

    # Buttons 4-6 are remapped by keyd but intentionally left unbound for now.
    # Their keysyms (verify with `wev` before binding):
    #   button 4 -> XF86Launch7
    #   button 5 -> f17 (sym unverified)
    #   button 6 -> f18 (sym unverified)
  };
}
