{config, ... }:
{
  virtualisation.oci-containers.containers.seerr = {
    image = "ghcr.io/seerr-team/seerr:latest";
    ports = [ "${builtins.toString config.custom.world.services.seerr.port}:5055" ];
    autoStart = true;
    user = "1000:100";
    extraOptions = [ "--network=media" ];
    environment = {
        LOG_LEVEL = "info";
    };
    volumes =
      [ "/data/seerr/config/:/app/config" ];
  };
}