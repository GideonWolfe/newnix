{ pkgs, lib, inputs, config, osConfig, ... }:
with config.lib.stylix.colors.withHashtag;
let
  niriPkg = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
in {
  imports = [ 
    inputs.niri.homeModules.niri 
    inputs.niri.homeModules.stylix 
    # Niri specific configs for waybar
    #./niri-waybar.nix 
    # Mako since Niri doesn't ship a notification service
    ../global/ui/mako/mako.nix
    # Dank Material Shell
    ../global/ui/dms/dms.nix
  ];

  # Keep upstream overlay so pkgs.niri-unstable exists
  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  programs.niri = {
    enable = true;
    package = lib.mkDefault niriPkg;

    settings = {
      # Session/env basics
      environment = {
        "NIXOS_OZONE_WL" = "1";
        "QT_QPA_PLATFORM" = "wayland";
      };

      # Startup commands (runs after session start)
      spawn-at-startup = [
        # Set wallpaper
        { command = [ "${lib.getExe pkgs.swww}" "img" "${osConfig.stylix.image}" ]; }
      ];

      prefer-no-csd = true;
      clipboard.disable-primary = true;
      screenshot-path = "${config.xdg.userDirs.pictures}/screenshots/%Y-%m-%d %H-%M-%S.png";

      # Input defaults
      input = {
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

      # Desktop layout
      layout = {
        gaps = 16;
        # Spacing around screen edges
        struts = {
          left = 64;
          right = 64;
        };

        # Give windows a border
        border = {
          enable = true;
          width = 2;
        };

        # Give Windows a shadow
        shadow = {
          enable = true;
        };

        # Highlight around currently focused window
        focus-ring = {
          active = {
            gradient = { 
              from = "${base0A}";
              to = "${base0E}"; 
              angle=45;
              relative-to="workspace-view";
            };
          };
        };

        # Indicator above tabbed window columns
        tab-indicator = {
          # Draw tab indicators at top of column
          position = "top";
          # Don't draw if column not tabbed
          hide-when-single-tab = true;
          # Take up total length of tab proportional to window
          length.total-proportion = 1.0;
          # Small gap between tabs
          gaps-between-tabs = 10;
          # Color of actively focused tab
          active = {
            gradient = { from = "${base0A}"; to = "${base0E}"; angle=45;};
          };
          # Color of tab when window is urgent
          urgent = {
            color = "${red}";
          };
        };

        # Hint when dragging windows in overview mode
        insert-hint = {
          display.gradient = {
            from = "${base0A}";
            to = "${base0E}";
            angle = 45;
            relative-to = "workspace-view";
          };
        };

        always-center-single-column = true;
        empty-workspace-above-first = true;
        default-column-display = "tabbed";
        # preset-column-widths = [ { proportion = 1.0 / 2.0; } { proportion = 1.0 / 3.0; } ];
        # Used when no wallpaper is set
        background-color = "${base00}";
      };

      overview = {
        zoom = 0.5;
        backdrop-color = "${base01}";
      };


      hotkey-overlay = {
          skip-at-startup = true;
          hide-not-bound = true;
      };

      # Binds: one entry per chord. Direct, readable form.
      binds = {

        # Spawn Terminal
        "Mod+Return".action.spawn = "kitty";
        # Close focused window
        "Mod+Shift+Q".action.close-window = [ ];
        # App launcher
        "Mod+D".action.spawn = "wofi --show run";
        # Quick exit
        "Mod+Shift+E".action.quit = [ ];

        # Window state toggles
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

        # Monitor focus/move for multi-monitor parity with Hyprland
        "Mod+Comma".action.focus-monitor-previous = [ ];
        "Mod+Period".action.focus-monitor-next = [ ];
        "Mod+Shift+Comma".action.move-window-to-monitor-previous = [ ];
        "Mod+Shift+Period".action.move-window-to-monitor-next = [ ];

        "Mod+BracketLeft".action.consume-or-expel-window-left = [ ];
        "Mod+BracketRight".action.consume-or-expel-window-right = [ ];

        # Toggle tabbed/stack display for current column
        "Mod+Space".action.toggle-column-tabbed-display = [ ];

        # Quick overview / workspace switcher
        "Mod+Tab".action.toggle-overview = [ ];

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
        # Screenshot via hyprshot -> swappy; use spawn-sh for the pipe
        "Print".action.spawn-sh = "hyprshot -m output --raw | swappy -f -";
      };

      # Outputs: define monitors/scale/position. Get names via `niri msg --json outputs`.
      # outputs = {
      #   "eDP-1" = {
      #     scale = 1.25;
      #     mode = {
      #       width = 2560;
      #       height = 1600;
      #       refresh = 60.0;
      #     };
      #     position = { x = 0; y = 0; };
      #   };
      #   "HDMI-A-1" = {
      #     enable = true;
      #     scale = 1.0;
      #     mode = {
      #       width = 1920;
      #       height = 1080;
      #       refresh = 60.0;
      #     };
      #     position = { x = 2560; y = 0; }; # to the right of eDP-1
      #   };
      # };

      # Window rules: match windows and tweak behavior/colors/floating.
      window-rules = [
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
        #   border.active.color = "#89b4fa";
        # }
      ];
    };
  };
}
