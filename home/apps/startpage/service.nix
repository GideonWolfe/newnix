{ pkgs, lib, config, osConfig, ... }:

let
  # Helper to build a full URL from a service's protocol and domain
  mkUrl = svc: "${svc.protocol}://${svc.domain}";

  services = osConfig.custom.world.services;
  colors = config.lib.stylix.colors.withHashtag;

  # Use replaceVars to inject world service URLs into the HTML at build time
  indexHtml = pkgs.replaceVars ./data/index.html {
    jellyfinUrl = mkUrl services.jellyfin;
    seerrUrl = mkUrl services.seerr;
    sonarrUrl = "http://${services.sonarr.ip}:${builtins.toString services.sonarr.port}";
    navidromeUrl = mkUrl services.navidrome;
  };

  # Use replaceVars to inject Stylix colors into the CSS at build time
  styleCss = pkgs.replaceVars ./data/style.css {
    base00 = colors.base00;
    base01 = colors.base01;
    base09 = colors.base09;
    base0A = colors.base0A;
    base0B = colors.base0B;
    base0C = colors.base0C;
    base0D = colors.base0D;
    base0E = colors.base0E;
  };

  # Create startpage data with templated HTML and CSS
  startpageData = pkgs.stdenv.mkDerivation {
    name = "startpage-data";
    src = ./data;
    installPhase = ''
      mkdir -p $out
      cp ${indexHtml} $out/index.html
      cp ${styleCss} $out/style.css
    '';
  };
in {
  # Serve startpage from Nix store with generated CSS
  systemd.user.services.startpage = {
    Unit = { Description = "startpage being served by miniserv"; };
    Install = { WantedBy = [ "default.target" ]; };
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = 1;
      WorkingDirectory = "${startpageData}";
      ExecStart = "${pkgs.miniserve}/bin/miniserve --index index.html -p 9876";
    };
  };
}
