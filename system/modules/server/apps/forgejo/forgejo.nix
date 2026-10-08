{ config, lib, pkgs, ... }:
let
  svc = config.custom.world.services.forgejo;
  dataDir = "/data/forgejo";
  codeDir = "/nas/tank/personal/code";
in
{
  virtualisation.oci-containers.containers.forgejo = {
    image = "codeberg.org/forgejo/forgejo:15.0.6-rootless@sha256:90a7b5b335dd84dbed7f031f2721ae877c713a9226a2b246bc0ed7e1fc7dd9ec";
    # Match the NAS's all_squash,anonuid=1000,anongid=100 without a host Git account.
    user = "1000:100";
    ports = [
      "${svc.ip}:${toString svc.port}:3000"
      "${svc.ip}:${toString svc.sshPort}:2222"
    ];
    volumes = [
      "${dataDir}:/var/lib/gitea"
      "${codeDir}:/code"
    ];
    environment = {
      TZ = config.time.timeZone;
      # Keep the existing database filename; the image already defaults to SQLite.
      FORGEJO__database__PATH = "/var/lib/gitea/data/forgejo.db";
      FORGEJO__repository__ROOT = "/code/repositories";
      FORGEJO__repository__DEFAULT_PRIVATE = "private";
      FORGEJO__lfs__PATH = "/code/lfs";
      FORGEJO__server__LFS_START_SERVER = "true";
      FORGEJO__server__DOMAIN = svc.ip;
      FORGEJO__server__ROOT_URL = "${svc.protocol}://${svc.ip}:${toString svc.port}/";
      FORGEJO__server__SSH_DOMAIN = svc.ip;
      FORGEJO__server__SSH_PORT = toString svc.sshPort;
      FORGEJO__service__DISABLE_REGISTRATION = "true";
      FORGEJO__service__REQUIRE_SIGNIN_VIEW = "true";
      # Override the v15 image's overly broad proxy default; no proxy auth is used.
      FORGEJO__security__REVERSE_PROXY_TRUSTED_PROXIES = "127.0.0.0/8,::1/128";
      FORGEJO__actions__ENABLED = "false";
      # INSTALL_LOCK is left to the one-time setup wizard and persisted in app.ini.
    };
    extraOptions = [
      "--cap-drop=ALL"
      "--security-opt=no-new-privileges=true"
    ];
  };

  systemd.services.docker-forgejo = {
    unitConfig.RequiresMountsFor = [ dataDir codeDir ];
    preStart = ''
      # Create only local state here; provision the NAS folders once as 1000:100.
      ${pkgs.coreutils}/bin/install -d -m 0700 -o 1000 -g 100 ${lib.escapeShellArg dataDir}
      test -d ${lib.escapeShellArg "${codeDir}/repositories"}
      test -d ${lib.escapeShellArg "${codeDir}/lfs"}
    '';
  };

  networking.firewall.allowedTCPPorts = [ svc.port svc.sshPort ];
}