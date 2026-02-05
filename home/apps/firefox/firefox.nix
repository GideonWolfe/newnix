{ pkgs, lib, config, ... }:

with config.lib.stylix.colors.withHashtag;

# Hack that lets me inject variables into the CSS at build time
let
  colors = config.lib.stylix.colors.withHashtag;
  userChromeCss = pkgs.replaceVars ./userChrome.css {
    base00 = colors.base00;
    base01 = colors.base01;
    base02 = colors.base02;
    base03 = colors.base03;
    base04 = colors.base04;
    base05 = colors.base05;
    base06 = colors.base06;
    base07 = colors.base07;
    base08 = colors.base08;
    base09 = colors.base09;
    base0A = colors.base0A;
    base0B = colors.base0B;
    base0C = colors.base0C;
    base0D = colors.base0D;
    base0E = colors.base0E;
    base0F = colors.base0F;
  };
  userContentCss = pkgs.replaceVars ./userContent.css {
    base00 = colors.base00;
    base01 = colors.base01;
    base02 = colors.base02;
    base03 = colors.base03;
    base04 = colors.base04;
    base05 = colors.base05;
    base06 = colors.base06;
    base07 = colors.base07;
    base08 = colors.base08;
    base09 = colors.base09;
    base0A = colors.base0A;
    base0B = colors.base0B;
    base0C = colors.base0C;
    base0D = colors.base0D;
    base0E = colors.base0E;
    base0F = colors.base0F;
  };
in

{
  # imports = [
  #   ./userChrome.nix
  #   ./userContent.nix
  # ];
  programs.firefox = {
    enable = true;

    # allow vdhcoapp to run in FF without setup step
    nativeMessagingHosts = [ pkgs.vdhcoapp ];

    # Change policies from https://mozilla.github.io/policy-templates/
    policies = {
      AppAutoUpdate = false;
      DisablePocket = true;
      DisableTelemetry = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DisableProfileImport =
        true; # Purity enforcement: Only allow nix-defined profiles
      DisableProfileRefresh =
        true; # Disable the Refresh Firefox button on about:support and support.mozilla.org
      DisableSetDesktopBackground =
        true; # Remove the “Set As Desktop Background…” menuitem when right clicking on an image, because Nix is the only thing that can manage the backgroud
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };
      FirefoxHome = {
        "Search" = true;
        "TopSites" = true;
        "SponsoredTopSites" = false;
        "Highlights" = false;
        "Pocket" = false;
        "SponsoredPocket" = false;
        #"Snippets" = true | false,
        #"Locked" = true | false
      };
      ShowHomeButton = true;

      FirefoxSuggest = {
        "WebSuggestions" = true;
        "SponsoredSuggestions" = false;
        "ImproveSuggest" = true;
        #"Locked" = true | false
      };
      #
      # How different mimetypes and file extensions are handled
      Handlers = {
        mimeTypes = {
          "application/msword" = {
            "action" = "useSystemDefault";
            "ask" = false;
          };
          "magnet" = {
            "action" = "useSystemDefault";
            "ask" = false;
          };
        };
      };

      ExtensionSettings = {
        # Ublock Origin
        "uBlock0@raymondhill.net" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          "default_area" = "menupanel";
        };
        # Vimium
        "{d7742d87-e61d-4b78-b8a1-b469842139fa}" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/vimium-ff/latest.xpi";
          "default_area" = "menupanel";
        };
        # Keepa (amazon price tracker)
        "amptra@keepa.com" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/keepa/latest.xpi";
          "default_area" = "menupanel";
        };
        # Dark Reader
        "addon@darkreader.org" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          "default_area" = "menupanel";
        };
        # New Tab Override
        "newtaboverride@agenedia.com" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/new-tab-override/latest.xpi";
          "default_area" = "menupanel";
        };
        # Bitwarden password manager
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          "default_area" = "menupanel";
        };
        # Floccus bookmarks
        "floccus@handmadeideas.org" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/floccus/latest.xpi";
          "default_area" = "menupanel";
        };
        # Hoarder
        # "addon@hoarder.app" = {
        #   "installation_mode" = "force_installed";
        #   "install_url" =
        #     "https://addons.mozilla.org/firefox/downloads/latest/hoarder-app/latest.xpi";
        #   "default_area" = "menupanel";
        # };
        # SponsorBlock
        "sponsorBlocker@ajay.app" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          "default_area" = "menupanel";
        };
        # Reddit Enhancement Suite
        "jid1-xUfzOsOFlzSOXg@jetpack" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/reddit-enhancement-suite/latest.xpi";
          "default_area" = "menupanel";
        };
        # ViolentMonkey
        "{aecec67f-0d10-4fa7-b7c7-609a2db280cf}" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/violentmonkey/latest.xpi";
          "default_area" = "menupanel";
        };
        # Video DownloadHelper
        # requires "vdhcoapp" companion app
        "{b9db16a4-6edc-47ec-a1f4-b86292ed211d}" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/video-downloadhelper/latest.xpi";
          "default_area" = "menupanel";
        };
        # I still don't care about cookies! autodenies/accepts EU cookie notifs
        "idcac-pub@guus.ninja" = {
          "installation_mode" = "force_installed";
          "install_url" =
            "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi";
          "default_area" = "menupanel";
        };
      };

    };

    profiles = {
      # test profile I'm building from scratch
      default = {

        name = "default";

        # set this to a predictable number
        id = 0;

        # Make it the default profile
        isDefault = true;

        # https://kb.mozillazine.org/About:config_entries
        settings = {

          # Enable Autoscroll
          "general.autoScroll" = true;

          # Enable Scrolling on tabs to switch
          "toolkit.tabbox.switchByScrolling" = true;

          # Change browser homepage
          "browser.startup.homepage" = "http://localhost:9876";

          # Always restore session
          "browser.startup.page" = 3;

          # Enable userChrome.css styling
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # Enable stylix fonts 
          "font.name.serif.x-western" = "${config.stylix.fonts.serif.name}";

          # The background of pages/text that don't declare one (such as skeleton HTML sites)
          "browser.display.background_color" = "${base00}";
          "browser.display.foreground_color" = "${base05}";
          "browser.display.use_focus_colors" = true;
          "browser.display.focus_background_color" = "${base01}";
          "browser.display.focus_text_color" = "${base04}";

          #TODO: test!! disables documents from setting their own colors
          "browser.display.use_document_colors" = false;
          "browser.display.use_document_fonts" = 1;

          # Selects "light" theme so websites don't automatically use dark mode
          # this works better for DarkReader
          "layout.css.prefers-color-scheme.content-override" = 1;

          # active/unvisited/visited links (if not otherwise themed)
          "browser.active_color" = "${base0C}";
          "browser.anchor_color" = "${base0D}";
          "browser.visited_color" = "${base0B}";

          # For thunderbird (n/a I think)
          "editor.background_color" = "${base00}";
          "editor.use_custom_colors" = true;

          # Selected text
          "ui.textSelectBackground" = "${base05}";
          "ui.textSelectForeground" = "${base00}";

          # Highlight text
          "ui.textHighlightBackground" = "${base05}";
          "ui.textHighlightForeground" = "${base00}";

          # Set the colors of the reader mode
          "reader.color_scheme" = "custom";
          "reader.custom_colors.background" = "${base00}";
          "reader.custom_colors.foreground" = "${base05}";
          "reader.custom_colors.selection-highlight" = "${base0E}";
          "reader.custom_colors.unvisited-links" = "${base0B}";
          "reader.custom_colors.visited-links" = "${base08}";

          # Colors available when using highlighter tool in PDF
          "pdfjs.highlightEditorColors" =
            "yellow=${base0A},green=${base0B},blue=${base0D},pink=${base0E},red=${base08}";

          # Use neovim to view source
          "view_source.editor.external" = true;
          "view_source.editor.path" = "${pkgs.alacritty}/bin/alacritty";
          "view_source.editor.args" = "--command nvim";

          # Some style settings
          "browser.chrome.favicons" = false;

          # enable debugging of firefox chrome through inspector
          "devtools.chrome.enabled" = true;
          "devtools.debugger.remote-enabled" = true;

          # Change colors of PDFJS pdf reader
          "pdfjs.forcePageColors" = true;
          "pdfjs.pageColorsBackground" = "${base00}";
          "pdfjs.pageColorsForeground" = "${base05}";

          # allow plugins on all pages
          "extensions.webextensions.restrictedDomains" = "";
          "extensions.webextensions.restrictedDomains.enabled" = false;
          "privacy.resistFingerprinting.block_mozAddonManager" = true;

          # Automatically install declared plugins
          #BUG: added on discord advice, doesn't seem to work
          "extensions.autoDisableScopes" = 0;

          # turn of google safebrowsing (it literally sends a sha sum of everything you download to google)
          "browser.safebrowsing.downloads.remote.block_dangerous" = false;
          "browser.safebrowsing.downloads.remote.block_dangerous_host" = false;
          "browser.safebrowsing.downloads.remote.block_potentially_unwanted" =
            false;
          "browser.safebrowsing.downloads.remote.block_uncommon" = false;
          "browser.safebrowsing.downloads.remote.url" = false;
          "browser.safebrowsing.downloads.remote.enabled" = false;
          "browser.safebrowsing.downloads.enabled" = false;

        };

        #search = {
        #	default = "DuckDuckGo";
        #	order = [
        #		"DuckDuckGo"
        #		"Google"
        #	];
        # Here is where I can put the config for individual engines
        #engines = {
        #	duckDuckGo = {};
        #};
        #};

        userChrome = builtins.readFile userChromeCss;
        userContent = builtins.readFile userContentCss;

        extensions = {
          # Required when defining extension settings to avoid accidental overrides
          force = true;
        };

        # Have to configure NUR, not sure if I want to do that
        #extensions = [
        #];
      };
    };
  };
}
