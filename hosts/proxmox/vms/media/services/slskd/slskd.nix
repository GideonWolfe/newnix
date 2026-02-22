{ config, ... }:
{
  virtualisation.oci-containers.containers.slskd = {
    image = "slskd/slskd:0.24.4";
    user= "1000:100";
    extraOptions = [ "--network=media" ];
    ports = [
      "${builtins.toString config.custom.world.services.slskd.port}:5030" # HTTP
      "5031:5031" # HTTPS #TODO: might need to swap these so HTTPS is the var
      "50300:50300"
    ];
    environment = {
      SLSKD_REMOTE_CONFIGURATION = "true";
    };
    autoStart = true;
    volumes = [
      "/data/slskd/app/:/app/"
      "/nas/tank/media/music/:/music/"
      "${config.custom.world.hosts.media.downloadsDir}:/downloads"
    ];
  };
}
