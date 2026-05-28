{ lib, config, ... }:
{
  sops = {
    secrets = {
      # Initial TA admin password (set on first boot for TA_USERNAME).
      # Generate with `openssl rand -base64 24`.
      "tubearchivist/ta_password" = { sopsFile = ./secrets_tubearchivist.yaml; };

      # Elasticsearch superuser password. Must be identical inside the TA
      # container and the ES container - both pull it from the same key.
      "tubearchivist/elastic_password" = { sopsFile = ./secrets_tubearchivist.yaml; };

      # Restic repo password for NAS-side backup (see ../tubearchivist_backup.nix).
      "tubearchivist/restic_password" = { sopsFile = ./secrets_tubearchivist.yaml; };
    };
  };

  # Single env file shared by TA + ES so the ELASTIC_PASSWORD agreement is
  # mechanically enforced (one source of truth). TA also needs TA_PASSWORD;
  # ES ignores it.
  sops.templates."tubearchivist-env".content = ''
    TA_PASSWORD=${config.sops.placeholder."tubearchivist/ta_password"}
    ELASTIC_PASSWORD=${config.sops.placeholder."tubearchivist/elastic_password"}
  '';
}
