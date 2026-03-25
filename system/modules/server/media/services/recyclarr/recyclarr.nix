{ pkgs, lib, config, ... }:

let
  recyclarrConfigDir = "/data/recyclarr2/config";
in
{
  virtualisation.oci-containers.containers.recyclarr = {
    # https://hub.docker.com/r/recyclarr/recyclarr/tags
    image = "recyclarr/recyclarr:7.5.2";
    autoStart = true;
    extraOptions = [ "--network=media" ];
    user= "1000:100";
    volumes = [
      "${recyclarrConfigDir}:/config/"
    ];
  };
}
