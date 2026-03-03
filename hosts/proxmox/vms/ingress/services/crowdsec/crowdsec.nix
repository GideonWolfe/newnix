{
  virtualisation.oci-containers.containers.crowdsec = {
    image = "crowdsecurity/crowdsec";
    ports = [ "4223:8080" ];
    autoStart = true;
    environment = {
      PGID = "1000";
      COLLECTIONS = "crowdsecurity/traefik crowdsecurity/http-cve crowdsecurity/appsec-generic-rules";
    };
    volumes = [
      # Standard crowdsec volumes for config and data
      "/var/lib/crowdsec/data/:/var/lib/crowdsec/data/"
      "/etc/crowdsec:/etc/crowdsec"

      # Where the Traefik logs are stored on the host,
      # mounted read-only into the container for CrowdSec to parse
      "/var/lib/traefik/logs/:/var/log/traefik/:ro"

      # The file that tells CrowdSec which logs to parse and how
      "/etc/crowdsec/acquis.yaml:/etc/crowdsec/acquis.yaml:ro"
    ];
  };

  # Render acquis.yaml locally so it can be mounted into the container
  environment.etc."crowdsec/acquis.yaml".text = ''
    ---
    filenames:
      - /var/log/traefik/access.log
    labels:
      type: traefik
  '';
}