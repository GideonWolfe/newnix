{config, ...}:
{
  # Ensure the data and cache directories exist with correct ownership
  # before the container starts, since navidrome runs as user 1000:100
  # and needs to create files under /data (unlike linuxserver.io images
  # which handle this automatically via PUID/PGID init scripts).
  systemd.tmpfiles.rules = [
    "d /data/navidrome/data 0755 1000 100 -"
    "d /data/navidrome/data/cache 0755 1000 100 -"
  ];

  virtualisation.oci-containers.containers.navidrome = {
    image = "deluan/navidrome:latest";
    ports = [ "${builtins.toString config.custom.world.services.navidrome.port}:4533" ];
    autoStart = true;
    user = "1000:100";
    extraOptions = [ "--network=media" ];
    environment = {
      ND_BASEURL = "https://${config.custom.world.services.navidrome.domain}";
    };
    volumes = [
      "/data/navidrome/data/:/data"
      "/nas/tank/media/music/:/music:ro"
    ];
  };
}
