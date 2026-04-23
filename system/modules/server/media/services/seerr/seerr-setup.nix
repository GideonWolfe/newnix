{ config, ... }:

let
  # Host-side path that is bind-mounted into the container as /app/config
  seerrConfigDir = "/data/seerr/config";
in
{
  ##########
  # Config #
  ##########
  # Pre-create the seerr config directory on the host with the right
  # ownership so the container (running as 1000:100) can write into it.
  # Without this, Docker resolves the bind mount and creates the path as
  # root:root 0755, causing seerr to EACCES on /app/config/logs.
  systemd.services.seerr-seed-config = {
    description = "Seed Seerr config dir";
    wantedBy = [ "multi-user.target" ];
    before = [ "docker-seerr.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      set -e
      mkdir -p ${seerrConfigDir}
      chown -R 1000:100 ${seerrConfigDir}
      chmod 0775 ${seerrConfigDir}
    '';
  };

  # Ensure the container waits for its config dir
  systemd.services.docker-seerr = {
    requires = [ "seerr-seed-config.service" ];
    after = [ "seerr-seed-config.service" ];
  };
}
