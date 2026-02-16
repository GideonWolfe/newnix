{
  virtualisation.oci-containers.containers.nzbget = {
    image = "linuxserver/nzbget:latest";
    ports = [ "${builtins.toString config.custom.world.services.nzbget.port}:6789" ];
    autoStart = true;
    environment = {
      NZBGET_USER = "test";
      NZBGET_PASS = "test";
      PUID = "1000";
      PGID = "100";
    };
    volumes = [
      "/data/nzbget/config/:/config"
      "${config.custom.world.hosts.media.downloadsDir}:/downloads"
    ];
  };

}