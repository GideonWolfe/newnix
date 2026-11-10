{ pkgs, inputs, lib, config, osConfig, ... }:
with config.lib.stylix.colors.withHashtag;
{
    # Use the home module directly; it wires dmsPkgs internally via mkModuleWithDmsPkgs.
    imports = [ 
        # Basic DMS home manager module
        inputs.dms.homeModules.dank-material-shell
        # Niri integration module (not using rn?)
        #inputs.dms.homeModules.niri
        # Make plugins available decleratively
        inputs.dms-plugin-registry.homeModules.default
        # search service for dms
        inputs.danksearch.homeModules.default
     ];

    # Stylix still emits the pre-v24 dockTransparency key; map opacity below.
    stylix.targets.dank-material-shell.opacity.enable = false;

    # DMS can miss watched-file changes when Home Manager replaces symlinks.
    systemd.user.services.dms.Unit.X-Restart-Triggers =
        lib.optionals config.programs.dank-material-shell.systemd.restartIfChanged (
            [
                config.xdg.configFile."dms/settings.json".source
                config.xdg.configFile."dms/plugin_settings.json".source
                config.xdg.configFile."dms/clsettings.json".source
            ]
            ++ lib.mapAttrsToList (_: plugin: toString plugin.src)
                (lib.filterAttrs (_: plugin: plugin.enable)
                    config.programs.dank-material-shell.plugins)
        );

    # Quick Capture uses wf-recorder for recording and these tools for exports/OCR.
    home.packages = with pkgs; [
        wf-recorder
        ffmpeg
        imagemagick
        img2pdf
        tesseract
        zbar
    ];

    programs.dank-material-shell = {
        enable = true;
        systemd.enable = true;
        # Only start DMS with Niri, not Hyprland.
        systemd.target = "niri.service";
        systemd.restartIfChanged = true;
        enableSystemMonitoring = true;
        #enableDynamicTheming = true;
        enableAudioWavelength = true;
        #enableCalendarEvents = true; # TODO: make dependent on khal/calendars being configured

        # Plugin Stuff
        # Nix manages plugin_settings.json separately from the shell settings.
        managePluginSettings = true;
        # Registry IDs include third-party plugins; plugins outside it need a pinned src.
        # List of plugins: https://github.com/duxlabs-dev/dux-plugin-registry
        plugins = {
            # Execute arbitrary actions from the DMS UI
            # TODO find a good use for this
            dankActions.enable = true;
            mediaPlayer = {
                enable = true;
                settings = { preferredSource = "spotify"; };
            };
            # dockerManager.enable = true;
            emojiLauncher.enable = true; 
            nixMonitor.enable = true;
            powerUsagePlugin.enable = true;
            # Niri specific UI to mirror displays
            displayMirror.enable = true; 
            # Niri specific UI to change display res, brightness, etc
            displayManager.enable = true; 
            # Niri specific UI to change windows
            niriWindows.enable = true; 
            alarmClock.enable = true;
            commandRunner.enable = true;
            calculator.enable = true;
            dankBitwarden.enable = true;
            dankLauncherKeys.enable = true;
            dankKDEConnect.enable = true;
            dankGifSearch.enable = true;
            dankDesktopWeather.enable = true;
            aiAssistant.enable = true;
            webSearch.enable = true;
            quickCapture.enable = true;
        };


        # Contents of DMS settings.json
        # To test changes, edit settings in DMS GUI.
        # Once desired config is reached, click "Copy settings.json to clipboard".
        # Convert with: nix run github:sempruijs/json2nix
        # Preserve Stylix values and portable paths below.
        # Migrate the settings structure before advancing configVersion.
        settings = {
            # Use our own custom color theme instead of stylix's DMS target colors.
            # Stylix still provides fonts and wallpaper; opacity is mapped below.
            # mkForce overrides the target's color theme file.
            currentThemeName = lib.mkForce "custom";
            currentThemeCategory = "generic";
            customThemeFile = lib.mkForce "${config.home.homeDirectory}/.config/DankMaterialShell/stylix.json";
            registryThemeVariants = {};
            matugenScheme = "scheme-content";
            runUserMatugenTemplates = false;
            matugenTargetMonitor = "";
            # The dock and bar follow the Stylix surface opacity.
            popupTransparency = config.stylix.opacity.popups;
            radiusStrength = 38;
            showSeconds = true;
            useFahrenheit = true;
            wallpaperFillMode = "Fill";
            density = "dense";
            barElevationEnabled = false;
            blurEnabled = false;
            blurStrength = 136;
            blurBorderEnabled = true;
            blurBorderSeeded = true;
            blurLayerOutlineOpacity = 0.03;
            blurredWallpaperLayer = false;
            blurWallpaperOnOverview = true;
            dmsWindowsFloatingSeeded = [ "niri" ];
            controlCenterWidgets = [
                {
                    id = "user";
                    enabled = true;
                    w = 5;
                    h = 1;
                }
                {
                    id = "settings";
                    enabled = true;
                    w = 1;
                    h = 1;
                    small = true;
                }
                {
                    id = "lock";
                    enabled = true;
                    w = 1;
                    h = 1;
                    small = true;
                }
                {
                    id = "power";
                    enabled = true;
                    w = 1;
                    h = 1;
                    small = true;
                }
                {
                    id = "volumeSlider";
                    enabled = true;
                    w = 4;
                    h = 1;
                }
                {
                    id = "brightnessSlider";
                    enabled = true;
                    w = 4;
                    h = 1;
                }
                {
                    id = "audioOutput";
                    enabled = true;
                    w = 4;
                    h = 1;
                }
                {
                    id = "audioInput";
                    enabled = true;
                    w = 4;
                    h = 1;
                }
                {
                    id = "wifi";
                    enabled = true;
                    w = 4;
                    h = 1;
                }
                {
                    id = "bluetooth";
                    enabled = true;
                    w = 4;
                    h = 1;
                }
                {
                    id = "builtin_vpn";
                    enabled = true;
                    w = 4;
                    h = 1;
                }
                {
                    id = "displayMirror";
                    enabled = true;
                    w = 4;
                    h = 1;
                }
                {
                    id = "nightMode";
                    enabled = true;
                    w = 2;
                    h = 1;
                }
                {
                    id = "idleInhibitor";
                    enabled = true;
                    w = 2;
                    h = 1;
                }
                {
                    id = "doNotDisturb";
                    enabled = true;
                    w = 2;
                    h = 1;
                }
                {
                    id = "edit";
                    enabled = true;
                    w = 1;
                    h = 1;
                    small = true;
                }
                {
                    id = "runningApps";
                    enabled = true;
                    w = 4;
                    h = 1;
                    small = true;
                    col = 0;
                    row = 6;
                }
            ];
            workspaceNameIcons = {
                gumbo = {
                    type = "icon";
                    value = "webhook";
                };
            };
            scrollTitleEnabled = true;
            audioVisualizerEnabled = true;
            appIdSubstitutions = [
                {
                    pattern = "Spotify";
                    replacement = "spotify";
                    type = "exact";
                }
                {
                    pattern = "beepertexts";
                    replacement = "beeper";
                    type = "exact";
                }
                {
                    pattern = "home assistant desktop";
                    replacement = "homeassistant-desktop";
                    type = "exact";
                }
                {
                    pattern = "com.transmissionbt.transmission";
                    replacement = "transmission-gtk";
                    type = "contains";
                }
                {
                    pattern = "^steam_app_(\\d+)$";
                    replacement = "steam_icon_$1";
                    type = "regex";
                }
            ];
            centeringMode = "index";
            clockDateFormat = "";
            lockDateFormat = "";
            sortAppsAlphabetically = false;
            appLauncherGridColumns = 4;
            niriOverviewOverlayEnabled = true;
            launcherStyle = "full";
            useAutoLocation = false;
            weatherEnabled = true;
            networkPreference = "auto";
            cursorSettings = {
                theme = "${osConfig.stylix.cursor.name}";
                size = osConfig.stylix.cursor.size;
                niri = {
                    hideWhenTyping = false;
                    hideAfterInactiveMs = 0;
                };
                hyprland = {
                    hideOnKeyPress = false;
                    hideOnTouch = false;
                    inactiveTimeout = 0;
                };
            };
            # fontFamily / monoFontFamily now set by stylix's DMS target
            # fontFamily = "${osConfig.stylix.fonts.sansSerif.name}";
            # monoFontFamily = "${osConfig.stylix.fonts.monospace.name}";
            fontWeight = 400;
            fontScale = 1;
            notepadUseMonospace = true;
            notepadFontFamily = "";
            notepadFontSize = 14;
            notepadShowLineNumbers = false;
            soundsEnabled = true;
            useSystemSoundTheme = false;
            soundNewNotification = false;
            soundVolumeChanged = true;
            soundPluggedIn = true;
            acMonitorTimeout = 0;
            acLockTimeout = 0;
            acSuspendTimeout = 0;
            acSuspendBehavior = 0;
            acProfileName = "";
            batteryMonitorTimeout = 1800;
            batteryLockTimeout = 900;
            batterySuspendTimeout = 3600;
            batterySuspendBehavior = 2;
            batteryProfileName = "";
            batteryChargeLimit = 100;
            lockBeforeSuspend = true;
            loginctlLockIntegration = true;
            fadeToLockEnabled = true;
            fadeToLockGracePeriod = 5;
            fadeToDpmsEnabled = true;
            fadeToDpmsGracePeriod = 5;
            launchPrefix = "";
            syncModeWithPortal = false;
            terminalsAlwaysDark = false;
            runDmsMatugenTemplates = false; # don't interfere with stylix!
            matugenTemplateGtk = false;
            matugenTemplateNiri = false;
            matugenTemplateHyprland = false;
            matugenTemplateMangowc = false;
            matugenTemplateQt5ct = false;
            matugenTemplateQt6ct = false;
            matugenTemplateFirefox = false;
            matugenTemplatePywalfox = false;
            matugenTemplateZenBrowser = false;
            matugenTemplateVesktop = false;
            matugenTemplateEquibop = false;
            matugenTemplateGhostty = false;
            matugenTemplateKitty = false;
            matugenTemplateFoot = false;
            matugenTemplateAlacritty = false;
            matugenTemplateNeovim = false;
            matugenTemplateWezterm = false;
            matugenTemplateDgop = false;
            matugenTemplateKcolorscheme = false;
            matugenTemplateVscode = false;
            ########
            # Dock #
            ########
            dockConfigs = [
                {
                    id = "dock";
                    name = "Dock";
                    enabled = false;
                    screenPreferences = [ "all" ];
                    showOnLastDisplay = true;
                    position = 3;
                    mode = "compact";
                    middleClickAction = "close";
                    taskbarAlign = "center";
                    widgetExpansion = "popout";
                    iconSize = 40;
                    spacing = 3;
                    itemSpacing = 4;
                    margin = 0;
                    bottomGap = 0;
                    transparency = 1;
                    followInterfaceStyle = true;
                    autoHide = false;
                    smartAutoHide = false;
                    useOverlayLayer = false;
                    editOnRightClick = false;
                    showOnFullscreen = false;
                    openOnOverview = true;
                    groupByApp = true;
                    separatePinnedAndRunningApps = false;
                    restoreSpecialWorkspaceOnClick = false;
                    isolateDisplays = true;
                    indicatorStyle = "line";
                    borderEnabled = true;
                    borderColor = "secondary";
                    borderOpacity = 0.5;
                    borderThickness = 1;
                    launcherEnabled = false;
                    launcherLogoMode = "apps";
                    launcherLogoCustomPath = "";
                    launcherLogoColorOverride = "";
                    launcherLogoSizeOffset = 0;
                    launcherLogoBrightness = 0.5;
                    launcherLogoContrast = 1;
                    maxVisibleApps = 0;
                    maxVisibleRunningApps = 0;
                    showOverflowBadge = true;
                    showTrash = false;
                    trashFileManager = "default";
                    trashCustomCommand = "";
                    magnification = false;
                    magnificationScale = 130;
                    magnificationProfile = "parabolic";
                    magnificationExpand = false;
                    order = [];
                    widgets = [
                        {
                            id = "dock_launcher";
                            widgetId = "dockLauncher";
                            enabled = true;
                        }
                        {
                            id = "dock_apps";
                            widgetId = "appsDock";
                            enabled = true;
                        }
                        {
                            id = "dock_trash";
                            widgetId = "dockTrash";
                            enabled = true;
                        }
                    ];
                }
            ];

            notificationOverlayEnabled = false;
            modalDarkenBackground = true;

            ###############
            # Lock Screen #
            ###############
            lockScreenShowPowerActions = true;
            lockScreenShowProfileImage = true;
            enableFprint = false;
            maxFprintTries = 15;
            lockScreenInactiveColor = "${base01}";
            lockScreenWidgetInstances = [
                {
                    id = "lock_date";
                    widgetType = "lockDate";
                    enabled = true;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                        format = "short";
                        colorMode = "default";
                        customColor = "#ffffff";
                    };
                }
                {
                    id = "lock_auth";
                    widgetType = "lockAuth";
                    enabled = true;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                        style = "expressive";
                        profileVisibility = "always";
                        passwordVisibility = "always";
                    };
                }
                {
                    id = "lock_notifications";
                    widgetType = "lockNotifications";
                    enabled = false;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                        mode = 2;
                    };
                }
                {
                    id = "lock_status";
                    widgetType = "lockStatus";
                    enabled = true;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                        showMediaPlayer = true;
                        showWeather = true;
                        background = false;
                    };
                }
                {
                    id = "lock_power";
                    widgetType = "lockPower";
                    enabled = true;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                        shape = "round";
                    };
                }
                {
                    id = "lw_1794322531791_1jqjypisn";
                    widgetType = "desktopClock";
                    name = "Clock";
                    enabled = true;
                    config = {
                        syncPositionAcrossScreens = true;
                        style = "overlap";
                        transparency = 0;
                        colorMode = "default";
                        customColor = "#ffffff";
                        showDate = true;
                        showAnalogNumbers = false;
                        showAnalogSeconds = true;
                        displayPreferences = [ "all" ];
                        autoPosition = false;
                        fontFamily = osConfig.stylix.fonts.monospace.name;
                        weight = 0;
                    };
                }
                {
                    id = "lw_1794322692203_3vje7d4df";
                    widgetType = "systemMonitor";
                    name = "System Monitor";
                    enabled = true;
                    config = {
                        syncPositionAcrossScreens = true;
                        showHeader = false;
                        transparency = 0;
                        colorMode = "secondary";
                        customColor = "#ffffff";
                        showCpu = true;
                        showCpuGraph = true;
                        showCpuTemp = true;
                        showGpuTemp = false;
                        gpuPciId = "";
                        showMemory = true;
                        showMemoryGraph = true;
                        showNetwork = true;
                        showNetworkGraph = true;
                        showDisk = true;
                        showTopProcesses = false;
                        topProcessCount = 3;
                        topProcessSortBy = "cpu";
                        layoutMode = "list";
                        graphInterval = 60;
                        displayPreferences = [ "all" ];
                    };
                }
            ];
            greeterWidgetInstances = [
                {
                    id = "lock_date";
                    widgetType = "lockDate";
                    enabled = true;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                        format = "short";
                        colorMode = "default";
                        customColor = "#ffffff";
                    };
                }
                {
                    id = "lock_auth";
                    widgetType = "lockAuth";
                    enabled = true;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                        style = "expressive";
                        profileVisibility = "always";
                        passwordVisibility = "always";
                    };
                }
                {
                    id = "lock_status";
                    widgetType = "lockStatus";
                    enabled = true;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                        showMediaPlayer = true;
                        showWeather = true;
                        background = false;
                    };
                }
                {
                    id = "lock_power";
                    widgetType = "lockPower";
                    enabled = true;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                        shape = "round";
                    };
                }
                {
                    id = "lw_1794322531791_1jqjypisn";
                    widgetType = "desktopClock";
                    name = "Clock";
                    enabled = true;
                    config = {
                        syncPositionAcrossScreens = true;
                        style = "overlap";
                        transparency = 0;
                        colorMode = "default";
                        customColor = "#ffffff";
                        showDate = true;
                        showAnalogNumbers = false;
                        showAnalogSeconds = true;
                        displayPreferences = [ "all" ];
                        autoPosition = false;
                        fontFamily = osConfig.stylix.fonts.monospace.name;
                        weight = 0;
                    };
                }
                {
                    id = "greeter_session";
                    widgetType = "greeterSession";
                    enabled = true;
                    config = {
                        displayPreferences = [ "all" ];
                        syncPositionAcrossScreens = true;
                    };
                }
            ];
            #########################
            # Notification Settings #
            #########################
            notificationTimeoutLow = 5000;
            notificationTimeoutNormal = 5000;
            notificationTimeoutCritical = 0;
            notificationCompactMode = false;
            notificationPopupPosition = 0;
            notificationHistoryEnabled = true;
            notificationHistoryMaxCount = 50;
            notificationHistoryMaxAgeDays = 7;
            notificationHistorySaveLow = true;
            notificationHistorySaveNormal = true;
            notificationHistorySaveCritical = true;
            #####################
            # On Screen Display #
            #####################
            osdAlwaysShowValue = true;
            osdPosition = 5;
            osdVolumeEnabled = true;
            osdMediaVolumeEnabled = true;
            osdBrightnessEnabled = true;
            osdIdleInhibitorEnabled = true;
            osdMicMuteEnabled = true;
            osdCapsLockEnabled = true;
            osdPowerProfileEnabled = false;
            osdAudioOutputEnabled = true;
            ##############
            # Power Menu #
            ##############
            powerActionConfirm = true;
            powerActionHoldDuration = 0.5;
            powerMenuActions = [
                "reboot"
                "logout"
                "poweroff"
                "lock"
                "suspend"
                "restart"
                "hibernate"
            ];
            powerMenuDefaultAction = "logout";
            powerMenuGridLayout = false;
            customPowerActionLock = "";
            customPowerActionLogout = "";
            customPowerActionSuspend = "";
            customPowerActionHibernate = "";
            customPowerActionReboot = "";
            customPowerActionPowerOff = "";
            updaterUseCustomCommand = false;
            updaterCustomCommand = "";
            updaterTerminalAdditionalParams = "";
            displayNameMode = "system";
            screenPreferences = {
                wallpaper = [];
            };
            showOnLastDisplay = {};
            connectedFrameBarStyleBackups = {};
            barConfigs = [
                {
                    id = "default";
                    name = "Main Bar";
                    enabled = true;
                    # 0 = top, 1=bottom, 2=left, 3=right
                    position = 0;
                    screenPreferences = [
                        "all"
                    ];
                    showOnLastDisplay = true;
                    leftWidgets = [
                        {
                            id = "launcherButton";
                            enabled = true;
                            launcherLogoMode = "custom";
                            launcherLogoCustomPath = "${config.home.homeDirectory}/profile.png";
                            launcherLogoColorOverride = "";
                            launcherLogoBrightness = 0.5;
                            launcherLogoContrast = 1;
                            launcherLogoSizeOffset = 0;
                        }
                        {
                            id = "workspaceSwitcher";
                            enabled = true;
                            showWorkspaceIndex = true;
                            showWorkspaceName = false;
                            showWorkspacePadding = false;
                            showWorkspaceApps = false;
                            maxWorkspaceIcons = 3;
                            groupWorkspaceApps = true;
                            workspaceFollowFocus = false;
                            showOccupiedWorkspacesOnly = false;
                            reverseScrolling = false;
                            dwlShowAllTags = false;
                            workspaceColorMode = "pri";
                            workspaceUnfocusedColorMode = "s";
                            workspaceUrgentColorMode = "err";
                            workspaceFocusedBorderEnabled = true;
                            workspaceFocusedBorderColor = "primary";
                            workspaceFocusedBorderThickness = 1;
                        }
                    ];
                    centerWidgets = [
                        {
                            id = "music";
                            enabled = true;
                            mediaSize = 1;
                            audioScrollMode = "volume";
                        }
                        {
                            id = "separator";
                            enabled = true;
                        }
                        {
                            id = "clock";
                            enabled = true;
                            clockCompactMode = false;
                        }
                        {
                            id = "separator";
                            enabled = true;
                        }
                        "weather"
                    ];
                    rightWidgets = [
                        {
                            id = "quickCapture";
                            enabled = true;
                        }
                        "notificationButton"
                        "idleInhibitor"
                        "clipboard"
                        "colorPicker"
                        "separator"
                        "battery"
                        {
                            id = "controlCenterButton";
                            enabled = true;
                            showNetworkIcon = true;
                            showVpnIcon = true;
                            showBluetoothIcon = true;
                            showAudioIcon = true;
                            showAudioPercent = false;
                            showMicIcon = false;
                            showMicPercent = false;
                            showBrightnessIcon = false;
                            showBrightnessPercent = false;
                            showBatteryIcon = false;
                            showPrinterIcon = false;
                            showScreenSharingIcon = true;
                        }
                        {
                            id = "privacyIndicator";
                            enabled = true;
                        }
                    ];
                    spacing = 0;
                    innerPadding = 4;
                    bottomGap = 0;
                    transparency = 1;
                    widgetTransparency = 1;
                    followInterfaceStyle = true;
                    widgetFollowInterfaceStyle = true;
                    widgetPadding = 5;
                    shadowIntensity = 0;
                    attachToScreenEdge = false;
                    dot = false;
                    island = false;
                    rightClickAction = "spotlight";
                    squareCorners = true;
                    noBackground = false;
                    gothCornersEnabled = false;
                    gothCornerRadiusOverride = false;
                    gothCornerRadiusValue = 12;
                    borderEnabled = true;
                    borderColor = "secondary";
                    borderOpacity = 0.45;
                    borderThickness = 1;
                    fontScale = 1;
                    autoHide = false;
                    autoHideDelay = 250;
                    openOnOverview = true;
                    visible = true;
                    popupGapsAuto = true;
                    popupGapsManual = 4;
                    widgetOutlineEnabled= false;
                    widgetOutlineOpacity= 0.50;
                    widgetOutlineColor= "primary";
                }
            ];
            # Desktop is empty; clock and system monitor are lock-screen instances.
            desktopWidgetInstances = [];
            desktopWidgetGroups = [];
            builtInPluginSettings = {
                dms_settings_search = {
                    trigger = "?";
                };
                dms_qr_generator = {
                    trigger = "qrg";
                };
                dms_power = {
                    trigger = "pw";
                };
                dms_clipboard_search = {
                    trigger = "cb";
                };
            };
            configVersion = 42;
            frameEnabled = false;

            # Theme related settings
            # Picking colors from the stylix theme and applying them to UI
            widgetBackgroundColor = "s";
            widgetColorMode = "colorful";
        };
        clipboardSettings = {
            maxItems = 100;
        };
    };

    # Export our own colors for DankMaterialShell as a JSON theme file.
    # Keep Stylix fonts, opacity, and wallpaper, but override the colors with
    # this file (referenced via settings.customThemeFile above).
    # Schema mirrors stylix's dank-material-shell target so no keys are missed.
    xdg.configFile."DankMaterialShell/stylix.json" = lib.mkIf (lib.hasAttr "stylix" config.lib) {
        text = builtins.toJSON (
          let
            theme = {
              name = "Custom";
              # Main accent color for buttons, highlights, and active states
              primary = blue;
              # Text color contrasting with primary background
              primaryText = base00;
              # Variant of primary for containers (settings menu button hover)
              primaryContainer = orange;
              # Supporting accent color (bar border)
              secondary = magenta;
              # Tint color applied to surfaces (dashboard page hover)
              surfaceTint = magenta;
              # Default surface color for cards and panels (bar section BGs)
              surface = base00;
              # Primary text color on surface backgrounds
              surfaceText = base05;
              # Alternate surface for subtle differentiation
              surfaceVariant = base01;
              # Text color for surfaceVariant backgrounds
              surfaceVariantText = base06;
              # Container surface, slightly different from surface
              surfaceContainer = base00;
              # Elevated container for cards/panels in menus
              surfaceContainerHigh = base01;
              # Highest elevation container for top-level surfaces
              surfaceContainerHighest = base02;
              # Main background color for the interface
              background = base00;
              # Text color for background areas
              backgroundText = base07;
              # Color for subtle borders, dividers, muted icons
              outline = magenta;
              # Status colors
              error = red;
              warning = orange;
              info = blue;
              success = green;
            };
          in
          {
            dark = theme;
            light = theme;
          }
        );
    };
    # Enable dsearch for DMS (system wide searching)
    programs.dsearch.enable = true;
}