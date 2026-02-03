{ pkgs, inputs, lib, config, ... }:
with config.lib.stylix.colors.withHashtag;
{
    # Use the home module directly; it wires dmsPkgs internally via mkModuleWithDmsPkgs.
    imports = [ inputs.dms.homeModules.dank-material-shell ];

    programs.dank-material-shell = {
        enable = true;
        systemd.enable = true;
        systemd.restartIfChanged = true;
        enableSystemMonitoring = false; # avoid dgop dependency not in pkgs
        #enableDynamicTheming = true;
        enableAudioWavelength = true;
        #enableCalendarEvents = true; # TODO: make dependent on khal/calendars being configured

        # Plugin Stuff
        # managePluginSettings = true;
        # plugins = {
        #     mediaPlayer = {
        #         enable = true;
        #         settings = { preferredSource = "spotify"; };
        #     };
            #calculator.enable = true;
            #commandRunner.enable = true;
            #dockerManager.enable = true;
            #emojiLauncher.enable = true;
            #nixMonitor.enable = true;
        #};


        settings = {
            # Lock screen before suspend (lid close, power button, etc.)
            lockBeforeSuspend = true;

            # Lock screen timeout (in seconds)
            lockTimeout = 900;  # 15 minutes

            # DPMS timeout (in seconds)
            dpmsTimeout = 930;  # 15.5 minutes

            # Bar position
            barPosition = "left";

            # Use a blurred wallpaper in the Niri overview
            blurWallpaperOnOverview = true;

        };
        clipboardSettings = {
            maxItems = 100;
        };
    };

    # Export Stylix colors for DankMaterialShell as a helper file.
    # xdg.configFile."DankMaterialShell/stylix.json" = lib.mkIf (lib.hasAttr "stylix" config.lib) {
    #     text = builtins.toJSON {
    #         dark = {
    #             name = "Stylix Colors";
    #             primary = colors.base0D;
    #             primaryText = colors.base05;
    #             primaryContainer = colors.base02;
    #             secondary = colors.base00;
    #             surface = colors.base00;
    #             surfaceText = colors.base05;
    #             surfaceVariant = colors.base03;
    #             surfaceVariantText = colors.base06;
    #             surfaceTint = colors.base04;
    #             background = colors.base00;
    #             backgroundText = colors.base07;
    #             outline = colors.base04;
    #             surfaceContainer = colors.base02;
    #             surfaceContainerHigh = colors.base03;
    #             error = colors.base08;
    #             warning = colors.base09;
    #             info = colors.base0A;
    #             success = colors.base0B;
    #         };
    #     };
    # };
}