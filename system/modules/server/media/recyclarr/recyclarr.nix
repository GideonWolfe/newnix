{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.recyclarr = {
    # https://hub.docker.com/r/recyclarr/recyclarr/tags
    image = "recyclarr/recyclarr:7.5.2";
    autoStart = true;
    user= "1000:100";
    # environment = {
    # };
    volumes = [
      "/data/recyclarr/config/:/config/"
    ];
  };

  # TODO configure secrets.yml with SOPS
  #  https://recyclarr.dev/reference/configuration/value-substitution/
}
