{ lib, config, ... }:
{
  sops = {
    secrets = {
      # Database password, used by both the postgres container (as
      # POSTGRES_PASSWORD) and the immich-server container (as DB_PASSWORD).
      "immich-db/password" = { sopsFile = ./secrets_immich.yaml; };

      # Restic repo password for the NAS-side backup (see ../immich_backup.nix).
      "immich/restic_password" = { sopsFile = ./secrets_immich.yaml; };
    };
  };

  # Env file mounted into immich-server (and immich-machine-learning).
  # See https://docs.immich.app/install/environment-variables
  sops.templates."immich-env".content = ''
    DB_PASSWORD=${config.sops.placeholder."immich-db/password"}
  '';

  # Env file mounted into the postgres container. POSTGRES_PASSWORD must
  # match DB_PASSWORD above so the server can authenticate against the DB.
  sops.templates."immich-db-env".content = ''
    POSTGRES_PASSWORD=${config.sops.placeholder."immich-db/password"}
  '';
}
