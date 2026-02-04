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
        inputs.dms-plugin-registry.modules.default
     ];

    programs.dank-material-shell = {
        enable = true;
        systemd.enable = true;
        systemd.restartIfChanged = true;
        # Pulling in dgop from unstable until its in stable
        dgop.package = inputs.dgop.packages.${pkgs.system}.default;
        enableSystemMonitoring = true;
        #enableDynamicTheming = true;
        enableAudioWavelength = true;
        #enableCalendarEvents = true; # TODO: make dependent on khal/calendars being configured

        # Plugin Stuff
        managePluginSettings = true;
        # List of plugins: https://github.com/AvengeMedia/dms-plugin-registry
        plugins = {
            # Execute arbitrary actions from the DMS UI
            # TODO find a good use for this
            dankActions.enable = true;
            mediaPlayer = {
                enable = true;
                settings = { preferredSource = "spotify"; };
            };
            # calculator.enable = true;
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
            dankBitwarden.enable = true;
            dankLauncherKeys.enable = true;
            dankKDEConnect.enable = true;
            dankDesktopWeather.enable = true;
            aiAssistant.enable = true;
        };


        # Contents of DMS settings.json
        # To test changes, edit settings in DMS GUI.
        # Once desired config is reached, click "Copy settings.json to clipboard"
        # Run that through json2nix: nix run github:sempruijs/json2nix
        settings = {
            currentThemeName = "custom";
            currentThemeCategory = "generic";
            customThemeFile = "${config.home.homeDirectory}/.config/DankMaterialShell/stylix.json";
            registryThemeVariants = {};
            matugenScheme = "scheme-content";
            runUserMatugenTemplates = false;
            matugenTargetMonitor = "";
            popupTransparency = 1;
            dockTransparency = 0.5;
            cornerRadius = 12;
            e24HourClock = true;
            showSeconds = true;
            useFahrenheit = true;
            nightModeEnabled = false;
            animationSpeed = 1;
            customAnimationDuration = 500;
            wallpaperFillMode = "Fill";
            blurredWallpaperLayer = false;
            blurWallpaperOnOverview = true;
            showLauncherButton = true;
            showWorkspaceSwitcher = true;
            showFocusedWindow = true;
            showWeather = true;
            showMusic = true;
            showClipboard = true;
            showCpuUsage = true;
            showMemUsage = true;
            showCpuTemp = true;
            showGpuTemp = true;
            selectedGpuIndex = 0;
            enabledGpuPciIds = [];
            showSystemTray = true;
            showClock = true;
            showNotificationButton = true;
            showBattery = true;
            showControlCenterButton = true;
            showCapsLockIndicator = true;
            controlCenterShowNetworkIcon = true;
            controlCenterShowBluetoothIcon = true;
            controlCenterShowAudioIcon = true;
            controlCenterShowAudioPercent = false;
            controlCenterShowVpnIcon = true;
            controlCenterShowBrightnessIcon = false;
            controlCenterShowBrightnessPercent = false;
            controlCenterShowMicIcon = false;
            controlCenterShowMicPercent = false;
            controlCenterShowBatteryIcon = false;
            controlCenterShowPrinterIcon = false;
            controlCenterShowScreenSharingIcon = true;
            showPrivacyButton = true;
            privacyShowMicIcon = false;
            privacyShowCameraIcon = false;
            privacyShowScreenShareIcon = false;
            controlCenterWidgets = [
                {
                    id = "volumeSlider";
                    enabled = true;
                    width = 50;
                }
                {
                    id = "brightnessSlider";
                    enabled = true;
                    width = 50;
                }
                {
                    id = "audioOutput";
                    enabled = true;
                    width = 50;
                }
                {
                    id = "audioInput";
                    enabled = true;
                    width = 50;
                }
                {
                    id = "wifi";
                    enabled = true;
                    width = 50;
                }
                {
                    id = "bluetooth";
                    enabled = true;
                    width = 50;
                }
                {
                    id = "builtin_vpn";
                    enabled = true;
                    width = 50;
                }
                {
                    id = "diskUsage";
                    enabled = true;
                    width = 50;
                    instanceId = "ml7895cb6zpw62o2h3leyuoeplfq39";# this value is idk??
                    mountPath = "/";
                }
                {
                    id = "colorPicker";
                    enabled = true;
                    width = 25;
                }
                {
                    id = "nightMode";
                    enabled = true;
                    width = 25;
                }
                {
                    id = "idleInhibitor";
                    enabled = true;
                    width = 25;
                }
                {
                    id = "doNotDisturb";
                    enabled = true;
                    width = 25;
                }
            ];
            showWorkspaceIndex = true;
            showWorkspaceName = false;
            showWorkspacePadding = false;
            workspaceScrolling = false;
            showWorkspaceApps = false;
            maxWorkspaceIcons = 3;
            groupWorkspaceApps = true;
            workspaceFollowFocus = false;
            showOccupiedWorkspacesOnly = false;
            reverseScrolling = false;
            dwlShowAllTags = false;
            workspaceNameIcons = {
                gumbo = {
                    type = "icon";
                    value = "webhook";
                };
            };
            waveProgressEnabled = true;
            scrollTitleEnabled = true;
            audioVisualizerEnabled = true;
            audioScrollMode = "volume";
            clockCompactMode = false;
            focusedWindowCompactMode = false;
            runningAppsCompactMode = true;
            keyboardLayoutNameCompactMode = false;
            runningAppsCurrentWorkspace = false;
            runningAppsGroupByApp = false;
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
            mediaSize = 1;
            appLauncherViewMode = "grid";
            spotlightModalViewMode = "list";
            sortAppsAlphabetically = false;
            appLauncherGridColumns = 4;
            spotlightCloseNiriOverview = true;
            niriOverviewOverlayEnabled = true;
            useAutoLocation = false;
            weatherEnabled = true;
            networkPreference = "auto";
            vpnLastConnected = "";
            iconTheme = "System Default";
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
            launcherLogoMode = "custom";
            launcherLogoCustomPath = "/home/${config.home.username}/profile.png";
            launcherLogoColorOverride = "";
            launcherLogoColorInvertOnMode = false;
            launcherLogoBrightness = 0.5;
            launcherLogoContrast = 1;
            launcherLogoSizeOffset = 0;
            fontFamily = "${osConfig.stylix.fonts.sansSerif.name}";
            monoFontFamily = "${osConfig.stylix.fonts.monospace.name}";
            fontWeight = 400;
            fontScale = 1;
            notepadUseMonospace = true;
            notepadFontFamily = "";
            notepadFontSize = 14;
            notepadShowLineNumbers = false;
            # notepadTransparencyOverride = "unknown character to parse: -";
            # ",
            # " = null;
            #adLastCustomTransparency = 0.7;
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
            brightnessDevicePins = {};
            wifiNetworkPins = {};
            bluetoothDevicePins = {};
            audioInputDevicePins = {};
            audioOutputDevicePins = {};
            gtkThemingEnabled = false;
            qtThemingEnabled = false;
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
            showDock = false;
            dockAutoHide = false;
            dockGroupByApp = true;
            dockOpenOnOverview = true;
            dockPosition = 1;
            dockSpacing = 3;
            dockBottomGap = 0;
            dockMargin = 0;
            dockIconSize = 40;
            dockIndicatorStyle = "line";
            dockBorderEnabled = true;
            dockBorderColor = "secondary";
            dockBorderOpacity = 0.5;
            dockBorderThickness = 1;
            dockIsolateDisplays = true;

            notificationOverlayEnabled = false;
            modalDarkenBackground = true;

            ###############
            # Lock Screen #
            ###############
            lockScreenShowPowerActions = true;
            lockScreenShowSystemIcons = true;
            lockScreenShowTime = true;
            lockScreenShowDate = true;
            lockScreenShowProfileImage = true;
            lockScreenShowPasswordField = true;
            enableFprint = false;
            maxFprintTries = 15;
            lockScreenActiveMonitor = "all";
            lockScreenInactiveColor = "${base01}";
            lockScreenNotificationMode = 0;
            hideBrightnessSlider = false;
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
            updaterHideWidget = true;
            updaterUseCustomCommand = false;
            updaterCustomCommand = "";
            updaterTerminalAdditionalParams = "";
            displayNameMode = "system";
            screenPreferences = {
                wallpaper = [];
            };
            showOnLastDisplay = {};
            niriOutputSettings = {};
            hyprlandOutputSettings = {};
            barConfigs = [
                {
                    id = "default";
                    name = "Main Bar";
                    enabled = true;
                    # 0 = top, 1 = bottom, 2, left
                    position = 0;
                    screenPreferences = [
                        "all"
                    ];
                    showOnLastDisplay = true;
                    leftWidgets = [
                        "launcherButton"
                        "workspaceSwitcher"
                        #"focusedWindow"
                    ];
                    centerWidgets = [
                        "music"
                        {
                            id = "separator";
                            enabled = true;
                        }
                        "clock"
                        {
                            id = "separator";
                            enabled = true;
                        }
                        "weather"
                    ];
                    rightWidgets = [
                        "notificationButton"
                        "idleInhibitor"
                        "clipboard"
                        "colorPicker"
                        #"cpuUsage"
                        #"memUsage"
                        "separator"
                        "battery"
                        "controlCenterButton"
                        # TODO kinda buggy lol
                        # {
                        #     id = "nixMonitor";
                        #     enabled = true;
                        # }
                        # {
                        #     id = "colorPicker";
                        #     enabled = true;
                        # }
                        # TODO extract to niri specific dms module later
                        # {
                        #     id = "displayManager";
                        #     enabled = true;
                        # }
                        "displayManager"
                        # don't really need now? maybe for udiskie
                        #"systemTray"
                    ];
                    spacing = 0;
                    innerPadding = 4;
                    bottomGap = 0;
                    transparency = 1;
                    widgetTransparency = 1;
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
            # Cool clock widget
            desktopClockEnabled = true;
            desktopClockStyle = "analog";
            desktopClockTransparency = 0.8;
            desktopClockColorMode = "secondary";
            desktopClockShowDate = true;
            desktopClockShowAnalogNumbers = false;
            desktopClockShowAnalogSeconds = true;
            #desktopClockX = "unknown character to parse: -";
            #",
            #" = "unknown character to parse: d";
            #sktopClockY = "unknown character to parse: -";
            #",
            #" = "unknown character to parse: d";
            desktopClockWidth = 280;
            desktopClockHeight = 180;
            desktopClockDisplayPreferences = [
                "all"
            ];
            systemMonitorEnabled = false;
            systemMonitorShowHeader = true;
            systemMonitorTransparency = 0.8;
            systemMonitorColorMode = "primary";
            # systemMonitorCustomColor = {
            #     r = 1;
            #     g = 1;
            #     b = 1;
            #     a = 1;
            #     hsvHue = "unknown character to parse: -";
            #     ",
            #     " = "unknown character to parse: h";
            #     vSaturation = 0;
            #     hsvValue = 1;
            #     hslHue = "unknown character to parse: -";
            #     ",
            #     " = "unknown character to parse: h";
            #     lSaturation = 0;
            #     hslLightness = 1;
            #     valid = true;
            # };
            systemMonitorShowCpu = true;
            systemMonitorShowCpuGraph = true;
            systemMonitorShowCpuTemp = true;
            systemMonitorShowGpuTemp = false;
            systemMonitorGpuPciId = "";
            systemMonitorShowMemory = true;
            systemMonitorShowMemoryGraph = true;
            systemMonitorShowNetwork = true;
            systemMonitorShowNetworkGraph = true;
            systemMonitorShowDisk = true;
            systemMonitorShowTopProcesses = false;
            systemMonitorTopProcessCount = 3;
            systemMonitorTopProcessSortBy = "cpu";
            systemMonitorGraphInterval = 60;
            systemMonitorLayoutMode = "auto";
            stemMonitorWidth = 320;
            systemMonitorHeight = 480;
            systemMonitorDisplayPreferences = [
                "all"
            ];
            systemMonitorVariants = [];
            desktopWidgetPositions = {};
            desktopWidgetGridSettings = {};
            desktopWidgetInstances = [];
            desktopWidgetGroups = [];
            builtInPluginSettings = {
                dms_settings_search = {
                    trigger = "?";
                };
            };
            configVersion = 5;


            # Theme related settings
            # Picking colors from the stylix theme and applying them to UI
            widgetBackgroundColor = "s";
            surfaceBase = "s";
            widgetColorMode = "colorful";
            # one of pri, s, sc, sch, none
            workspaceColorMode = "pri";
            # one of def, s, sc, sch
            workspaceUnfocusedColorMode = "s";
            # one of err, pri, sec, s, sc
            workspaceUrgentColorMode = "err";
            workspaceFocusedBorderEnabled = true;
            workspaceFocusedBorderColor = "primary";
            workspaceFocusedBorderThickness = 1;






        };
        clipboardSettings = {
            maxItems = 100;
        };
    };

    # Export Stylix colors for DankMaterialShell as a JSON theme file
    xdg.configFile."DankMaterialShell/stylix.json" = lib.mkIf (lib.hasAttr "stylix" config.lib) {
        text = builtins.toJSON {
            name = "Stylix Colors";
            # Main accent color for buttons, highlights, and active states
            # Used by: active workspace button bg, widget buttons, sliders, etc
            primary = blue;
            # Text color contrasting with primary background
            primaryText = base00;
            # Variant of primary for containers
            # used by: hovering over certain settings menu buttons (add widget),
            primaryContainer = orange;
            # Supporting accent color for variety and hierarchy
            #secondary = base00;
            # used by: Bar border, 
            secondary = magenta;
            # Tint color applied to surfaces (usually derived from primary)
            # ONLY seen when hovering over pages in dashboard
            surfaceTint = magenta;
            # Default surface color for cards and panels
            # used by: bottom compass in weather panel, flipped menu switch knobs, bar section BGs
            surface = base01;
            # Alternate surface for subtle differentiation
            surfaceVariant = base00;
            # Container surface, slightly different from surface
            surfaceContainer = base01;
            # Elevated container for layered interfaces
            # used by: basically all cards/panels in menus
            surfaceContainerHigh = base00;
            # Highest elevation container for top-level 
            surfaceContainerHighest = base02;
            # Primary text color on surface backgrounds
            surfaceText = base05;
            # Text color for surfaceVariant backgrounds
            surfaceVariantText = base06;
            # Main background color for the interface
            # used by: pause icon in media player
            background = base00; 
            # Text color for background areas
            backgroundText = base07;
            # Color for subtle borders, dividers, muted icons, and extra subtle text
            outline = magenta;
            # Status colors
            error = red;
            warning = orange;
            info = blue;
            success = green;
        };
    };
}