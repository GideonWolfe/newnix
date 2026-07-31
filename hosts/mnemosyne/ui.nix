{ lib, pkgs, osConfig, ... }:
let
  grafana = osConfig.custom.world.services.grafana;
  # Dashboard to display fullscreen. Replace <uid>/<slug> with the real
  # dashboard path; `kiosk` hides Grafana chrome and `refresh` auto-updates.
  # Hit Grafana directly over the LAN (IP:port) rather than the Traefik domain.
  dashboardUrl = "${grafana.protocol}://${grafana.ip}:${toString grafana.port}/d/agv29mj/nas-screen?kiosk&refresh=30s";
in
{
  # This host drives a small always-on panel, so disable all idle behavior
  # (screen off / lock / suspend) by overriding the shared DMS defaults.
  programs.dank-material-shell.settings = {
    acMonitorTimeout = lib.mkForce 0;
    acLockTimeout = lib.mkForce 0;
    acSuspendTimeout = lib.mkForce 0;
    batteryMonitorTimeout = lib.mkForce 0;
    batteryLockTimeout = lib.mkForce 0;
    batterySuspendTimeout = lib.mkForce 0;
    fadeToDpmsEnabled = lib.mkForce false;
    fadeToLockEnabled = lib.mkForce false;
    lockBeforeSuspend = lib.mkForce false;
  };

  # Launch Chromium in kiosk mode pointed at the Grafana dashboard on session start
  programs.niri.settings.spawn-at-startup = [
    {
      command = [
        "${lib.getExe pkgs.chromium}"
        "--kiosk"
        "--noerrdialogs"
        "--disable-infobars"
        "--incognito"
        "--start-fullscreen"
        dashboardUrl
      ];
    }
  ];
}
