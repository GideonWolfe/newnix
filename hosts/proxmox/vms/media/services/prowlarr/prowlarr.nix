{ pkgs, lib, config, ... }:
{
  virtualisation.oci-containers.containers.prowlarr = {
    # https://hub.docker.com/r/linuxserver/prowlarr/tags
    image = "linuxserver/prowlarr:2.3.0";
    ports = [ "${builtins.toString config.custom.world.services.prowlarr.port}:9696" ];
    autoStart = true;
    volumes = [
      "/data/prowlarr/config/:/config/"
    ];
  };
}
