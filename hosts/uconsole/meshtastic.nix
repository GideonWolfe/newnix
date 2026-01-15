{ config, lib, pkgs, ... }:

# Meshtastic/LoRa configuration for HackerGadgets uConsole AIO Extension Board
# Reference: https://hackergadgets.com/pages/hackergadgets-uconsole-rtl-sdr-lora-gps-rtc-usb-hub-all-in-one-extension-board-setup-guide

let
  cfg = config.services.meshtasticd;

  # Package meshtasticd from official releases
  meshtasticd = pkgs.stdenv.mkDerivation rec {
    pname = "meshtasticd";
    version = "2.5.18.89ebafc";

    src = pkgs.fetchurl {
      url = "https://github.com/meshtastic/firmware/releases/download/v${version}/meshtasticd_${version}_arm64.deb";
      sha256 = "12hppjda5ar35zf86yjqazcipn8c1lqbnjix362v8yphmyijrz0i";
    };

    nativeBuildInputs = [ pkgs.dpkg ];

    buildInputs = [
      pkgs.libgpiod
      pkgs.yaml-cpp
      pkgs.bluez
      pkgs.libusb1
      pkgs.i2c-tools
      pkgs.openssl
    ];

    unpackPhase = ''
      dpkg-deb -x $src .
    '';

    installPhase = ''
      mkdir -p $out/bin $out/share/meshtasticd $out/etc/meshtasticd
      cp -r usr/sbin/* $out/bin/
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
        Must be configured via the web interface on first use.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Add SPI1 overlay to config.txt for LoRa module
    # CM4 needs: dtparam=spi=on and dtoverlay=spi1-1cs
    boot.loader.rpi.config_txt = lib.mkAfter ''
      # SPI1 for LoRa/Meshtastic
      dtparam=spi=on
      dtoverlay=spi1-1cs
    '';

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
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/meshtasticd -c ${configFile}";
        Restart = "always";
        RestartSec = 5;

        # Run as root for hardware access (SPI, GPIO)
        User = "root";
        Group = "root";

        # Security hardening (limited due to hardware access needs)
        ProtectHome = true;
        PrivateTmp = true;
      };
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

    # Helpful assertions
    assertions = [
      {
        assertion = cfg.gps.enable -> config.services.gpsd.enable or false;
        message = "GPS is enabled for meshtasticd but gpsd service is not enabled. Consider enabling services.gpsd.";
      }
    ];
  };
}
