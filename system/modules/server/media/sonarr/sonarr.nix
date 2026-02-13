{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.sonarr = {
    image = "linuxserver/sonarr:latest";
    ports = [ "${builtins.toString config.custom.world.services.sonarr.port}:8989" ];
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    volumes = [
      "/data/sonarr/config/:/config/"
      "/nas/tank/media/tv/:/tv/"
      #"/pool/data/media/downloads/:/downloads"
    ];
  };
}
