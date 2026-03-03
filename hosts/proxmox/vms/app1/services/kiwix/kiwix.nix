{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.kiwix-serve = {
    image = "ghcr.io/kiwix/kiwix-serve";
    ports = [ "${config.custom.world.services.kiwix.port}:8080" ];
    autoStart = true;
    # TODO change to NAS path
    volumes = [ "/pool/data/media/zim:/data" ];
    cmd = [ "--verbose" "--address=0.0.0.0" "*.zim" ];
  };
}