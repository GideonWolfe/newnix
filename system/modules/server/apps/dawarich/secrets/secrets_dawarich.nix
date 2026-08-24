{ lib, config, ... }:
{
  sops = {
    secrets = {
      # SECRET_KEY_BASE for Rails + DATABASE_PASSWORD for the app containers.
      "dawarich/secret_key_base" = { sopsFile = ./secrets_dawarich.yaml; };
      "dawarich-db/password"     = { sopsFile = ./secrets_dawarich.yaml; };

      # Restic repo password for the NAS-side backup (see ../dawarich_backup.nix).
      "dawarich/restic_password" = { sopsFile = ./secrets_dawarich.yaml; };

      # Personal API key (generated in the Dawarich UI: Account -> API key) used
      # by the GPX exporter to pull raw points (see ../dawarich_gpx_export.nix).
      "dawarich/api_key" = { sopsFile = ./secrets_dawarich.yaml; };
    };
  };

  # Env file mounted into dawarich-app and dawarich-sidekiq.
  sops.templates."dawarich-env".content = ''
    SECRET_KEY_BASE=${config.sops.placeholder."dawarich/secret_key_base"}
    DATABASE_PASSWORD=${config.sops.placeholder."dawarich-db/password"}
  '';

  # Env file mounted into dawarich-db (postgres container).
  sops.templates."dawarich-db-env".content = ''
    POSTGRES_PASSWORD=${config.sops.placeholder."dawarich-db/password"}
  '';
}
