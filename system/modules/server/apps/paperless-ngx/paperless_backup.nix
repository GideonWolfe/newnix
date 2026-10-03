{ config, lib, pkgs, ... }:
let
  cfg = config.services.paperless;
  backupRepo = "/nas/tank/infra/services/paperless/restic_backup";
in
{
  # The native exporter stops Paperless, exports consistent metadata, then restarts it.
  services.paperless.exporter = {
    enable = true;
    directory = "${cfg.dataDir}/export";
    onCalendar = null; # Run synchronously before Restic, not on a second timer.
    settings."data-only" = true;
  };

  # A synchronous start waits for completion only with oneshot, not the upstream simple type.
  systemd.services.paperless-exporter.serviceConfig.Type = "oneshot";

  # Give in-flight OCR time to finish when the exporter stops the workers.
  systemd.services.paperless-task-queue.serviceConfig.TimeoutStopSec = "35min";

  services.restic.backups.paperless = {
    # No live SQLite copy or duplicate NAS documents. Indexes/previews can be rebuilt.
    paths = [ cfg.exporter.directory "${cfg.dataDir}/nixos-paperless-secret-key" ];
    repository = backupRepo;
    initialize = true;
    user = cfg.user;
    passwordFile = config.sops.secrets."paperless/restic_password".path;
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
    backupPrepareCommand = ''
      set -eu
      umask 077
      ${pkgs.coreutils}/bin/test -s ${lib.escapeShellArg "${cfg.exporter.directory}/manifest.json"}
      ${pkgs.coreutils}/bin/printf '%s\n' ${lib.escapeShellArg cfg.package.version} \
        > ${lib.escapeShellArg "${cfg.exporter.directory}/paperless-version.txt"}
    '';
  };

  systemd.services.restic-backups-paperless = {
    unitConfig.RequiresMountsFor = [ cfg.dataDir backupRepo ];
    # Avoid Requires=exporter: its app-restart conflicts must not propagate a stop to Restic.
    # Only this fixed start command runs as root; export and backup keep the paperless identity.
    serviceConfig.ExecStartPre = lib.mkBefore [
      "+${lib.getExe' config.systemd.package "systemctl"} start paperless-exporter.service"
    ];
  };
}