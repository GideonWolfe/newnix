{ pkgs, lib, config, ... }:

{
  # https://github.com/actualbudget/actual/blob/master/packages/sync-server/docker-compose.yml
  virtualisation.oci-containers.containers.actualbudget = {
    image = "actualbudget/actual-server:26.2.1";
    ports = [ "${config.custom.world.services.actualbudget.port}:5006" ];
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    volumes = [
      "/data/actualbudget/data/:/data"
    ];
  };
}