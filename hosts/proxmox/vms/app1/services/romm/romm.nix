{ pkgs, lib, config, ... }:
{
  virtualisation.oci-containers.containers.romm = {
    image = "rommapp/romm:4.6.1";
    ports = [ "${config.custom.world.services.romm.port}:8080" ];
    autoStart = true;
    # https://docs.romm.app/4.5.0/Getting-Started/Environment-Variables/
    environment = {
      PUID = "1000";
      PGID = "100";
      DB_HOST = "romm-db";
      DB_NAME = "romm";
    };
    volumes = [
      "/data/romm/resources:/romm/resources"
      "/data/romm/redis_data:/redis-data"
      # TODO finalize library location
      ":/romm/library"
      "/data/romm/assets:/romm/assets"
      "/data/romm/config:/romm/config"
    ];
    extraOptions = [ "--network=romm-network" ];
    dependsOn = [ "romm-db" ];
    environmentFiles = [ config.sops.secrets."romm/env".path ];
  };

  virtualisation.oci-containers.containers.romm-db = {
    image = "mariadb:latest";
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      MARIADB_DATABASE = "romm";
    };
    volumes = [
      "/data/romm/romm_database:/var/lib/mysql"
    ];
    # TODO ensure this is actually created
    extraOptions = [ "--network=romm-network" ];
    environmentFiles = [ config.sops.secrets."romm-db/env".path ];
  };
}