{ pkgs, lib, inputs, config, ... }:
let
  niriPkg = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
in {
  imports = [ inputs.niri.homeModules.niri ];

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
      prefer-no-csd = true;
      clipboard.disable-primary = true;
      screenshot-path = "${config.xdg.userDirs.pictures}/screenshots/%Y-%m-%d %H-%M-%S.png";

      # Input defaults
      input = {
        keyboard.xkb.layout = "us";
        mouse.accel-speed = 1.0;
        mouse.scroll-factor = 3;
        touchpad = {
          tap = true;
          dwt = true;
          natural-scroll = true;
          click-method = "clickfinger";
        };
        # focus-follows-mouse = { enable = true; max-scroll-amount = "0%"; };
        # workspace-auto-back-and-forth = true;
      };

      # Desktop layout
      layout = {
        gaps = 16;
        struts.left = 64;
        struts.right = 64;
        always-center-single-column = true;
        empty-workspace-above-first = true;
        border = {
          enable = true;
          width = 4;
        };
        shadow = {
          enable = true;
          # color = "#0007";
          # softness = 20;
          # spread = 5;
          # offset = { x = 0; y = 5; };
        };
        default-column-display = "tabbed";
        tab-indicator = {
          position = "top";
          gaps-between-tabs = 10;
          # hide-when-single-tab = true;
        };
        # preset-column-widths = [ { proportion = 1.0 / 2.0; } { proportion = 1.0 / 3.0; } ];
      };

      overview.zoom = 0.5;

      # ------------------------------------------------------------
      # Simple skeletons to copy/paste (all commented)
      # ------------------------------------------------------------

      # Startup commands (runs after session start)
      # spawn-at-startup = [
      #   { command = [ "${pkgs.waybar}/bin/waybar" ]; }
      #   { command = [ "${pkgs.mako}/bin/mako" ]; }
      #   { command = [ "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1" ]; }
      #   { command = [ "swww-daemon" ]; }
      #   { command = [ "swww" "img" "~/images/background.png" ]; }
      # ];

      # Binds: one entry per chord. Direct, readable form.
      binds = {
        "Mod+Return".action.spawn = "kitty";          # launch terminal
        "Mod+Shift+Q".action.close-window = [ ];       # close focused window

        # Vim-style focus navigation
        "Mod+H".action.focus-column-left = [ ];
        "Mod+L".action.focus-column-right = [ ];
        "Mod+J".action.focus-window-down = [ ];
        "Mod+K".action.focus-window-up = [ ];

        # Vim-style movement of windows/columns
        "Mod+Shift+H".action.move-column-left = [ ];
        "Mod+Shift+L".action.move-column-right = [ ];
        "Mod+Shift+J".action.move-window-down = [ ];
        "Mod+Shift+K".action.move-window-up = [ ];

        # Uncomment/add more as needed
        "Mod+D".action.spawn = "wofi --show run";
        # "Mod+Shift+E".action.quit = [ ];
        # "Mod+Space".action.toggle-column-tabbed-display = [ ];
        # "Mod+1".action.focus-workspace = 1;
        # "Mod+Shift+1".action.move-window-to-workspace = 1;
        # "XF86AudioRaiseVolume".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        # "XF86AudioLowerVolume".action.spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
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
      # window-rules = [
      #   {
      #     matches = [ { app-id = "^firefox$"; } ];
      #     block-out-from = "screencast";
      #   }
      #   {
      #     matches = [ { title = "^Picture in Picture$"; } ];
      #     open-floating = true;
      #     default-floating-position = { relative-to = "top-right"; x = -32; y = 32; };
      #   }
      #   {
      #     matches = [ { app-id = "^signal$"; } ];
      #     border.active.color = "#89b4fa";
      #   }
      # ];
    };
  };
}
