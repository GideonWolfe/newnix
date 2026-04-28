{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.bazarr = {
    image = "linuxserver/bazarr:latest";
    ports = [ "${builtins.toString config.custom.world.services.bazarr.port}:6767" ];
    autoStart = true;
    environment = {
      PUID = "1000";
      PGID = "100";
    };
    volumes = [
      #"/pool/data/services/media/bazarr/data/:/config/"
      "/data/bazarr/config/:/config/"
      "/nas/tank/media/tv/:/tv/"
      "/nas/tank/media/movies/:/movies/"
    ];
    extraOptions = [ "--network=media" ];
  };
}