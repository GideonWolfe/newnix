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

  # Pre-create the bind-mount target with 1000:100 ownership so docker
  # (which runs as root) doesn't create it as root on first start.
  # Matches PUID=1000/PGID=100 above. The NFS-mounted /nas/tank/media
  # paths are provisioned on mnemosyne, not via tmpfiles here.
  systemd.tmpfiles.rules = [
    "d /data/bazarr         0755 1000 100 - -"
    "d /data/bazarr/config  0755 1000 100 - -"
  ];
}