{ lib, config, ... }:
#
# FreshRSS secrets.
#
# Follows the env-var pattern from the official docker-compose example:
#   https://hub.docker.com/r/freshrss/freshrss#docker-compose
# These variables are consumed at first-run by FRESHRSS_INSTALL /
# FRESHRSS_USER auto-install in freshrss.nix.
#
{
  sops.secrets = {
    "freshrss/admin_email"        = { sopsFile = ./secrets_freshrss.yaml; };
    "freshrss/admin_password"     = { sopsFile = ./secrets_freshrss.yaml; };
    "freshrss/admin_api_password" = { sopsFile = ./secrets_freshrss.yaml; };
  };

  # Env file consumed by the freshrss container via `environmentFiles`.
  sops.templates."freshrss-env".content = ''
    ADMIN_EMAIL=${config.sops.placeholder."freshrss/admin_email"}
    ADMIN_PASSWORD=${config.sops.placeholder."freshrss/admin_password"}
    ADMIN_API_PASSWORD=${config.sops.placeholder."freshrss/admin_api_password"}
  '';
}
