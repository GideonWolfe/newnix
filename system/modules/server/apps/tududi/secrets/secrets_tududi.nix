{ config, ... }:
{
  sops.secrets = {
    "tududi/database_password" = { sopsFile = ./secrets_tududi.yaml; };
    "tududi/user_password" = { sopsFile = ./secrets_tududi.yaml; };
    "tududi/session_secret" = { sopsFile = ./secrets_tududi.yaml; };
    "tududi/restic_password" = {
      sopsFile = ./secrets_tududi.yaml;
      owner = "gideon";
    };
  };

  # PostgreSQL and the application share this password through separate
  # environment files; it is not embedded in the Nix store.
  sops.templates."tududi-db-env".content = ''
    POSTGRES_PASSWORD=${config.sops.placeholder."tududi/database_password"}
  '';

  sops.templates."tududi-env".content = ''
    DATABASE_URL=postgres://tududi:${config.sops.placeholder."tududi/database_password"}@tududi-db:5432/tududi
    TUDUDI_USER_PASSWORD=${config.sops.placeholder."tududi/user_password"}
    TUDUDI_SESSION_SECRET=${config.sops.placeholder."tududi/session_secret"}
  '';
}