{config, pkgs, ...}:
{
  # Define a SOPS template for the Managarr secrets.yml
  # Uses the Sonarr API key SOPS secret
  sops.templates."managarr-config.yml".content = ''
    radarr:
      - host: http://${config.custom.world.services.radarr.ip}
        port: ${builtins.toString config.custom.world.services.radarr.port}
        api_token: ${config.sops.placeholder."radarr/apikey"}
    sonarr:
      - host: http://${config.custom.world.services.sonarr.ip}
        port: ${builtins.toString config.custom.world.services.sonarr.port}
        api_token: ${config.sops.placeholder."sonarr/apikey"}
  '';
}