{ config, lib, pkgs, ... }:
let
  cfg = config.services.paperless;
  svc = config.custom.world.services.paperless;
in
{
  services.paperless = {
    enable = true;
    dataDir = "/data/paperless";
    # Paperless creates its normal documents/{originals,archive,thumbnails} layout here.
    mediaDir = "/nas/tank/personal/docs";
    consumptionDir = "${cfg.dataDir}/consume";
    database.createLocally = false; # SQLite on local ext4, never on NFS.
    passwordFile = config.sops.secrets."paperless/admin_pass".path;
    address = svc.ip;
    port = svc.port;
    settings = {
      PAPERLESS_URL = "${svc.protocol}://${if svc.domain != "" then svc.domain else "${svc.ip}:${toString svc.port}"}";
      PAPERLESS_ALLOWED_HOSTS = lib.concatStringsSep "," (
        [ svc.ip "localhost" "127.0.0.1" ] ++ lib.optional (svc.domain != "") svc.domain
      );
      PAPERLESS_ADMIN_USER = "admin";

      # Real paths, shared by originals and archive PDFs; IDs avoid title collisions.
      PAPERLESS_FILENAME_FORMAT = "{{ correspondent }}/{{ document_type }}/{{ created_year }}/{{ created }} - {{ title }} - {{ doc_pk }}";
      PAPERLESS_FILENAME_FORMAT_REMOVE_NONE = true;
      PAPERLESS_OCR_LANGUAGE = "eng";
      PAPERLESS_OCR_MODE = "skip";
      PAPERLESS_OCR_OUTPUT_TYPE = "pdfa";
      PAPERLESS_OCR_SKIP_ARCHIVE_FILE = "never";

      # Leave CPU headroom for the other apps on this VM.
      PAPERLESS_TASK_WORKERS = 1;
      PAPERLESS_THREADS_PER_WORKER = 2;
      PAPERLESS_CONSUMER_RECURSIVE = true;
    };
  };

  # Keep a dedicated service identity; the shared NAS group allows document access.
  users.users.${cfg.user}.extraGroups = [ "users" ];

  # Wait for the local disk and NAS before any process accesses its files.
  systemd.services = lib.genAttrs [
    "paperless-scheduler"
    "paperless-task-queue"
    "paperless-consumer"
    "paperless-web"
    "paperless-exporter"
  ] (_: {
    unitConfig.RequiresMountsFor = [ cfg.dataDir cfg.mediaDir ];
    serviceConfig.UMask = lib.mkForce "0027";
    # tmpfiles refuses the gideon-owned /data -> paperless-owned child transition.
    # Create only local directories after mounting; '+' runs this command as root.
    serviceConfig.ExecStartPre = lib.mkBefore [
      "+${pkgs.coreutils}/bin/install -d -m 0700 -o ${cfg.user} -g ${config.users.users.${cfg.user}.group} ${cfg.dataDir} ${cfg.consumptionDir} ${cfg.exporter.directory}"
    ];
  });

  systemd.tmpfiles.settings."10-paperless" = {
    "${cfg.dataDir}".d.mode = "0700";
    "${cfg.consumptionDir}".d.mode = "0700";
    # Provision this once on the NAS; don't chown it as root over root-squashed NFS.
    "${cfg.mediaDir}" = lib.mkForce { };
  };

  networking.firewall.allowedTCPPorts = [ svc.port ];
}