{ lib, pkgs, config, ... }:

let
  cfg = config.services.hamdash;

  defaultConfig = ./config.js;

  defaultPackage = pkgs.stdenv.mkDerivation {
    pname = "hamdashboard";
    version = "unstable-2026-01-23";
    src = pkgs.fetchzip {
      url = "https://github.com/VA3HDL/hamdashboard/archive/refs/heads/main.tar.gz";
      hash = "1rwv6xbcq5fp036y2bf4l3jfvz3naf1pizlyny0x9jghinxxjis6";
      stripRoot = true;
    };
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/hamdash
      cp -r ./* $out/share/hamdash/
      runHook postInstall
    '';
  };

  selectedConfig =
    if cfg.configFile != null then cfg.configFile else if cfg.configText != "" || cfg.disableSetup then
      pkgs.writeText "config.js" ''
        ${cfg.configText}
        ${lib.optionalString cfg.disableSetup "const disableSetup = true;\n"}
      ''
    else defaultConfig;

  docRoot = pkgs.runCommand "hamdash-docroot" {} ''
    mkdir -p $out
    cp -r ${cfg.package}/share/hamdash/* $out/
    rm -f $out/config.js
    ln -s ${selectedConfig} $out/config.js
    if [ ! -e $out/index.html ] && [ -e $out/hamdash.html ]; then
      ln -s hamdash.html $out/index.html
    fi
  '';
in
{
  options.services.hamdash = {
    enable = lib.mkEnableOption "Ham Dashboard static site";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      defaultText = "hamdashboard package fetched from upstream main";
      description = "Derivation that provides the hamdashboard static files.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address miniserve listens on.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8136;
      description = "TCP port to serve hamdashboard on.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for the hamdash port.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a config.js file to serve; overrides inline configText.";
    };

    configText = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        const defaultTiles = [
          ["wxradar", "https://radar.weather.gov/ridge/standard/KTLX_loop.gif", 300]
        ];
        const disableSetup = true;
      '';
      description = "Inline config.js content; use for simple dashboards without writing a separate file.";
    };

    disableSetup = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Append const disableSetup = true when generating config.js from configText.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.configFile == null || cfg.configText == "";
        message = "Set either services.hamdash.configFile or configText, not both.";
      }
    ];

    systemd.services.hamdash = {
      description = "Ham Dashboard served by miniserve";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 2;
        ExecStart = ''
          ${pkgs.miniserve}/bin/miniserve \
            --index hamdash.html \
            --interfaces ${cfg.listenAddress} \
            --port ${toString cfg.port} \
            ${docRoot}
        '';
      };
    };

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [ cfg.port ];
  };
}
