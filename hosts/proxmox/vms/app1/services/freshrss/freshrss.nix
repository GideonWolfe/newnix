{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.freshrss = {
    image = "lscr.io/linuxserver/freshrss:latest";
    ports = [ "${config.custom.world.services.freshrss.port}:80" ];
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
      TZ = "America/New_York";
    };
    volumes = [ "/data/freshrss/config/:/config" ];
  };
}