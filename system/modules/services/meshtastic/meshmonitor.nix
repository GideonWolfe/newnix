{ pkgs, lib, config, ... }:

{
  virtualisation.oci-containers.containers.homarr = {
    image = "ghcr.io/yeraze/meshmonitor:latest";
    ports = [ "8576:3001" ];
    autoStart = true;
    environment = {
      MESHTASTIC_NODE_IP = "192.168.0.73"; # change this to the IP of your main Meshtastic node. Templatize in future
    };
    volumes = [
      "/services/meshmonitor/data/:/data"
    ];
  };

}
