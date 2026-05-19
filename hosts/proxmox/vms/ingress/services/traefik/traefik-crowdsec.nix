{ config, ... }:
{

  # Install the plugin 
  services.traefik.staticConfigOptions.experimental.plugins.bouncer = {
    moduleName = "github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin";
    version = "v1.6.0";
  };

  # Enable the bouncer
  services.traefik.dynamicConfigOptions.http.middlewares.crowdsec.plugin = {
    bouncer = {
      enabled = "true";
      logLevel = "DEBUG";
      crowdsecLapiKeyFile = "${config.sops.secrets."crowdsec/api_key".path}";
      crowdsecMode = "live";
      # Use the service IP and port from our world config
      crowdsecLapiHost = "${config.custom.world.services.crowdsec.ip}:${builtins.toString config.custom.world.services.crowdsec.port}";
    };
  };

  # Inject it as middleware into our entrypoints.
  # Middlewares is a list, and entryPoints live under staticConfigOptions.
  services.traefik.staticConfigOptions.entryPoints.http.http.middlewares = [ "crowdsec@file" ];
  services.traefik.staticConfigOptions.entryPoints.https.http.middlewares = [ "crowdsec@file" ];

  # NOTE: upstream traefik module in 25.11 already sets WorkingDirectory to
  # /var/lib/traefik, so the old workaround for the plugin-storage path is no
  # longer needed.
}
