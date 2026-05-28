{ lib, config, ... }:
#
# Homepage Dashboard secrets.
#
# Homepage supports secret interpolation in its YAML config via env vars
# prefixed with `HOMEPAGE_VAR_`. Inside services.yaml / widgets we then
# reference them as `{{HOMEPAGE_VAR_NAME}}`.
#   https://gethomepage.dev/installation/docker/#using-environment-secrets
#
# Some self-hosted apps (e.g. calibre-web / calibre-web-automated) don't
# expose an API key and the Homepage widget requires the *user* login
# instead, so we keep those credentials here.
#
# To populate the encrypted yaml the first time:
#   cd system/modules/server/apps/homepage/secrets
#   sops secrets_homepage.yaml
# and add:
#   homepage:
#       calibre_username: <your calibre-web user>
#       calibre_password: <your calibre-web password>
#
{
  sops.secrets = {
    "homepage/calibre_username" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/calibre_password" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/immich_api_key" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/mealie_api_key" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/mikrotik_username" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/mikrotik_password" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/navidrome_token" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/navidrome_salt" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/nzbget_username" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/nzbget_password" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/sonarr_apikey" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/radarr_apikey" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/seerr_api_key" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/jellyfin_api_key" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/bazarr_api_key" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/prowlarr_api_key" = { sopsFile = ./secrets_homepage.yaml; };
    "homepage/karakeep_api_key" = { sopsFile = ./secrets_homepage.yaml; };
  };

  # Env file consumed by the homepage-dashboard systemd unit via
  # `services.homepage-dashboard.environmentFiles`. Every variable here
  # becomes available to Homepage's YAML loader as `{{HOMEPAGE_VAR_*}}`.
  sops.templates."homepage-env".content = ''
    HOMEPAGE_VAR_CALIBRE_USERNAME=${config.sops.placeholder."homepage/calibre_username"}
    HOMEPAGE_VAR_CALIBRE_PASSWORD=${config.sops.placeholder."homepage/calibre_password"}
    HOMEPAGE_VAR_IMMICH_API_KEY=${config.sops.placeholder."homepage/immich_api_key"}
    HOMEPAGE_VAR_MEALIE_API_KEY=${config.sops.placeholder."homepage/mealie_api_key"}
    HOMEPAGE_VAR_MIKROTIK_USERNAME=${config.sops.placeholder."homepage/mikrotik_username"}
    HOMEPAGE_VAR_MIKROTIK_PASSWORD=${config.sops.placeholder."homepage/mikrotik_password"}
    HOMEPAGE_VAR_NAVIDROME_TOKEN=${config.sops.placeholder."homepage/navidrome_token"}
    HOMEPAGE_VAR_NAVIDROME_SALT=${config.sops.placeholder."homepage/navidrome_salt"}
    HOMEPAGE_VAR_NZBGET_USERNAME=${config.sops.placeholder."homepage/nzbget_username"}
    HOMEPAGE_VAR_NZBGET_PASSWORD=${config.sops.placeholder."homepage/nzbget_password"}
    HOMEPAGE_VAR_SONARR_APIKEY=${config.sops.placeholder."homepage/sonarr_apikey"}
    HOMEPAGE_VAR_RADARR_APIKEY=${config.sops.placeholder."homepage/radarr_apikey"}
    HOMEPAGE_VAR_SEERR_API_KEY=${config.sops.placeholder."homepage/seerr_api_key"}
    HOMEPAGE_VAR_JELLYFIN_API_KEY=${config.sops.placeholder."homepage/jellyfin_api_key"}
    HOMEPAGE_VAR_BAZARR_API_KEY=${config.sops.placeholder."homepage/bazarr_api_key"}
    HOMEPAGE_VAR_PROWLARR_API_KEY=${config.sops.placeholder."homepage/prowlarr_api_key"}
    HOMEPAGE_VAR_KARAKEEP_API_KEY=${config.sops.placeholder."homepage/karakeep_api_key"}
  '';
}
