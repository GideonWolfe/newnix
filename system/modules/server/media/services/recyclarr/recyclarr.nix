{ pkgs, lib, config, ... }:

let
  recyclarrConfigDir = "/data/recyclarr/config";
in
{
  virtualisation.oci-containers.containers.recyclarr = {
    # https://hub.docker.com/r/recyclarr/recyclarr/tags
    image = "recyclarr/recyclarr:8.5.1";
    autoStart = true;
    extraOptions = [ "--network=media" ];
    user= "1000:100";
    volumes = [
      "${recyclarrConfigDir}:/config/"
    ];
  };
}
