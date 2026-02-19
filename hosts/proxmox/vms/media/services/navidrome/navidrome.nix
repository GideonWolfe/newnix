{config, ...}:
{
  virtualisation.oci-containers.containers.navidrome = {
    image = "deluan/navidrome:latest";
    ports = [ "${config.custom.world.services.navidrome.port}:4533" ];
    autoStart = true;
    user = "1000:100";
    environment = {
      ND_BASEURL = "https://${config.custom.world.services.navidrome.domain}";
    };
    volumes = [
      "/data/navidrome/data/:/data"
      "/nas/tank/media/music/:/music:ro"
    ];
  };
}
