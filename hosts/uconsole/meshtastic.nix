{ config, lib, pkgs, ... }:

# Meshtastic/LoRa configuration for HackerGadgets uConsole AIO Extension Board
# Reference: https://hackergadgets.com/pages/hackergadgets-uconsole-rtl-sdr-lora-gps-rtc-usb-hub-all-in-one-extension-board-setup-guide
# Meshtasticd docs: https://meshtastic.org/docs/hardware/devices/linux-native-hardware/

let
  cfg = config.services.meshtasticd;

  # Orcania - utility functions library required by Ulfius
  orcania = pkgs.stdenv.mkDerivation rec {
    pname = "orcania";
    version = "2.3.3";
    src = pkgs.fetchFromGitHub {
      owner = "babelouest";
      repo = "orcania";
      rev = "v${version}";
      sha256 = "sha256-Cz3IE5UrfoWjMxQ/+iR1bLsYxf5DVN+7aJqLBcPjduA=";
    };
    nativeBuildInputs = [ pkgs.cmake ];
    meta.platforms = lib.platforms.linux;
  };

  # Yder - logging library required by Ulfius
  yder = pkgs.stdenv.mkDerivation rec {
    pname = "yder";
    version = "1.4.20";
    src = pkgs.fetchFromGitHub {
      owner = "babelouest";
      repo = "yder";
      rev = "v${version}";
      sha256 = "sha256-BaCF1r5mOYxj0zKc11uoKI9gVKuxWd8GaneGcV+qIFg=";
    };
    nativeBuildInputs = [ pkgs.cmake ];
    buildInputs = [ orcania pkgs.systemd ];
    cmakeFlags = [ "-DWITH_JOURNALD=OFF" ];
    meta.platforms = lib.platforms.linux;
  };

  # Ulfius - HTTP framework required by meshtasticd web server
  ulfius = pkgs.stdenv.mkDerivation rec {
    pname = "ulfius";
    version = "2.7.15";
    src = pkgs.fetchFromGitHub {
      owner = "babelouest";
      repo = "ulfius";
      rev = "v${version}";
      sha256 = "sha256-YvMhcobvTEm4LxhNxi1MJX8N7VAB3YOvp+LxioJrKHU=";
    };
    nativeBuildInputs = [ pkgs.cmake pkg-config ];
    buildInputs = [ orcania yder pkgs.libmicrohttpd pkgs.curl pkgs.jansson pkgs.gnutls pkgs.libtasn1 pkgs.zlib ];
    cmakeFlags = [ "-DWITH_WEBSOCKET=OFF" "-DWITH_GNUTLS=OFF" ];
    meta.platforms = lib.platforms.linux;
  };

  inherit (pkgs) pkg-config;

  # Package meshtasticd from OpenSUSE Build Service (official builds)
  # v2.7.15 uses modern library versions that are all in nixpkgs
  meshtasticd = pkgs.stdenv.mkDerivation rec {
    pname = "meshtasticd";
    version = "2.7.15";

    src = pkgs.fetchurl {
      # The ~ in the filename causes issues with nix-prefetch-url, so we download locally
      # Original URL: https://download.opensuse.org/repositories/network:/Meshtastic:/beta/Debian_13/arm64/meshtasticd_2.7.15.48~obsd18f3f7~beta_arm64.deb
      url = "https://download.opensuse.org/repositories/network:/Meshtastic:/beta/Debian_13/arm64/meshtasticd_2.7.15.48~obsd18f3f7~beta_arm64.deb";
      sha256 = "sha256-MAdkZh9o1BaB9BAUw8Ltk5KtFP56xitpcRCUryDQxTA=";
      name = "meshtasticd-${version}.deb";
    };

    nativeBuildInputs = [
      pkgs.dpkg
      pkgs.autoPatchelfHook
    ];

    buildInputs = [
      pkgs.stdenv.cc.cc.lib  # libstdc++
      pkgs.libgpiod          # libgpiod.so.3 (v2.x)
      pkgs.yaml-cpp          # libyaml-cpp.so.0.8
      pkgs.libusb1           # libusb-1.0.so.0
      pkgs.i2c-tools         # libi2c.so.0
      pkgs.libuv             # libuv.so.1
      pkgs.xorg.libX11       # libX11.so.6
      pkgs.libinput          # libinput.so.10
      pkgs.libxkbcommon      # libxkbcommon.so.0
      pkgs.openssl           # libcrypto.so.3
      orcania                # liborcania.so.2.3
      ulfius                 # libulfius.so.2.7
    ];

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      mkdir -p $out/bin $out/share/meshtasticd $out/etc/meshtasticd
      # v2.7.x has binary in /usr/bin instead of /usr/sbin
      cp -r usr/bin/* $out/bin/
      cp -r usr/share/meshtasticd/* $out/share/meshtasticd/
      cp -r etc/meshtasticd/* $out/etc/meshtasticd/ || true
    '';

    meta = with lib; {
      description = "Meshtastic daemon for Linux-native LoRa mesh networking";
      homepage = "https://meshtastic.org/";
      license = licenses.gpl3;
      platforms = [ "aarch64-linux" ];
    };
  };

  # Generate the YAML config file for HackerGadgets AIO board
  configFile = pkgs.writeText "meshtasticd-config.yaml" ''
    Lora:
      Module: sx1262  # HackerGadgets AIO board uses SX1262
      DIO2_AS_RF_SWITCH: true
      DIO3_TCXO_VOLTAGE: true
      IRQ: 26
      Busy: 24
      Reset: 25
      spidev: spidev1.0

    General:
      MaxNodes: 200

    ${lib.optionalString cfg.gps.enable ''
    GPS:
      SerialPath: ${cfg.gps.device}
    ''}

    ${lib.optionalString cfg.webserver.enable ''
    Webserver:
      Port: ${toString cfg.webserver.port}
      RootPath: ${meshtasticd}/share/meshtasticd/web
    ''}
  '';

in {
  options.services.meshtasticd = {
    enable = lib.mkEnableOption "Meshtastic daemon for LoRa mesh networking";

    package = lib.mkOption {
      type = lib.types.package;
      default = meshtasticd;
      description = "The meshtasticd package to use";
    };

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to automatically start meshtasticd on boot. Set to false for debugging.";
    };

    gps = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable GPS integration with meshtasticd";
      };

      device = lib.mkOption {
        type = lib.types.str;
        default = "/dev/ttyS0";
        description = "Serial device for GPS module (use /dev/ttyAMA0 for CM5)";
      };
    };

    webserver = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the meshtasticd web interface";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 443;
        description = "Port for the web interface";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Open the firewall for the web interface";
      };
    };

    loraRegion = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [
        "US" "EU_868" "EU_433" "CN" "JP" "ANZ" "KR" "TW" "RU" "IN" "NZ_865" "TH" "UA_868" "UA_433" "MY_919" "SG_923" "LORA_24"
      ]);
      default = null;
      description = ''
        LoRa region setting. This determines the frequency band used.
        Different regions cannot communicate with each other.
        
        NOTE: This option is currently informational only. The region must be
        configured via the web interface or Python CLI on first use:
          meshtastic --host localhost --set lora.region US
        
        The region is stored in the device's persistent preferences, not the
        YAML config file.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # NOTE: You must manually add "dtoverlay=spi1-1cs" to your boot.loader.rpi.config_txt
    # in bootloader.nix for LoRa to work. We can't append here because config_txt is a
    # string type, not lines type.
    # 
    # Do NOT use dtparam=spi=on - it enables SPI0 which conflicts with something on uConsole.
    # We only need SPI1 for LoRa.

    # Install meshtasticd and useful tools
    environment.systemPackages = [
      cfg.package
      pkgs.contact # Meshtastic TUI client
      pkgs.python312Packages.meshtastic # Python CLI/API
    ];

    # Meshtasticd systemd service
    systemd.services.meshtasticd = {
      description = "Meshtastic Daemon";
      after = [ "network.target" ];
      wantedBy = lib.mkIf cfg.autoStart [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/meshtasticd -c ${configFile}";
        Restart = "always";
        RestartSec = 5;

        # Run as root for hardware access (SPI, GPIO)
        User = "root";
        Group = "root";

        # Security hardening (limited due to hardware access needs)
        # Note: ProtectHome is NOT used because meshtasticd stores state in /root/.portduino/
        PrivateTmp = true;
      };

      # Ensure state directory exists before starting
      preStart = ''
        mkdir -p /root/.portduino/default/prefs
      '';
    };

    # udev rules for SPI and GPIO access
    services.udev.extraRules = ''
      # SPI devices for LoRa
      SUBSYSTEM=="spidev", GROUP="wheel", MODE="0660"

      # GPIO access for LoRa module control pins
      SUBSYSTEM=="gpio", GROUP="wheel", MODE="0660"
    '';

    # Open firewall if configured
    networking.firewall.allowedTCPPorts =
      lib.mkIf (cfg.webserver.enable && cfg.webserver.openFirewall) [ cfg.webserver.port ];
  };
}
