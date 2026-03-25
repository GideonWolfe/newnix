{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.kiwix-serve = {
    image = "ghcr.io/kiwix/kiwix-serve:3.8.2";
    ports = [ "${builtins.toString config.custom.world.services.kiwix.port}:8080" ];
    autoStart = true;
    volumes = [ "/nas/tank/personal/prepping/zims:/data" ];
    cmd = [ "--verbose" "*.zim" ];
  };
}