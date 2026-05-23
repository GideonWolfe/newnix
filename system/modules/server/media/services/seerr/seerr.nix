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

  # Pre-create the bind-mount target with 1000:100 ownership so docker
  # (which runs as root) doesn't create it as root on first start.
  # Matches `user = "1000:100"` above.
  systemd.tmpfiles.rules = [
    "d /data/seerr         0755 1000 100 - -"
    "d /data/seerr/config  0755 1000 100 - -"
  ];
}