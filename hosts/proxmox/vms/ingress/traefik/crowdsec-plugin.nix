{

  # Install the plugin
  services.traefik.staticConfigurations.experimental.plugins.bouncer = {
    moduleName = "github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin";
    version = "v1.3.3";
  };

  # Enable the bouncer
  services.traefik.dynamicConfigOptions.http.middlewares.crowdsec.plugin = {
    bouncer = {
      enabled = "true";
      logLevel = "DEBUG";
      crowdsecLapiKeyFile = "${config.sops.secrets."crowdsec/api_key".path}";
      crowdsecMode = "live";
      crowdsecLapiHost = "192.168.0.158:4223";
    };
  };

  # Inject it as middleware into our entrypoints
  services.traefik.entrypoints.http.http.middlewares = "crowdsec@file";
  services.traefik.entrypoints.https.http.middlewares = "crowdsec@file";

  #HACK: since the nix service doesn't set this,
  # Traefik tries to install plugins to /plugins-storage,
  # which isn't in the ReadWritePaths
  systemd.services.traefik.serviceConfig = {
    WorkingDirectory = "/var/lib/traefik/";
  };
}
