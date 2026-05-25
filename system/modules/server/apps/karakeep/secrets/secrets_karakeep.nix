{ lib, config, ... }:
{
  sops = {
    secrets = {
      # NextAuth session signing key (random 36+ bytes; generate with
      # `openssl rand -base64 36`). Rotating this invalidates all sessions.
      "karakeep/nextauth_secret" = { sopsFile = ./secrets_karakeep.yaml; };

      # Meilisearch master key — must match between web and meili containers.
      # Also generate with `openssl rand -base64 36`.
      "karakeep/meili_master_key" = { sopsFile = ./secrets_karakeep.yaml; };

      # Optional: OpenAI key for auto-tagging. Leave commented until needed.
      # "karakeep/openai_api_key" = { sopsFile = ./secrets_karakeep.yaml; };

      # Restic repo password for the NAS-side backup (see ../karakeep_backup.nix).
      "karakeep/restic_password" = { sopsFile = ./secrets_karakeep.yaml; };
    };
  };

  # Env file mounted into karakeep-web. NEXTAUTH_URL is NOT here on purpose
  # — it's plain config and lives in the static `environment` block.
  #
  # To enable OpenAI auto-tagging, uncomment the `karakeep/openai_api_key`
  # secret above, then append a line to this template:
  #   OPENAI_API_KEY=''${config.sops.placeholder."karakeep/openai_api_key"}
  sops.templates."karakeep-web-env".content = ''
    NEXTAUTH_SECRET=${config.sops.placeholder."karakeep/nextauth_secret"}
    MEILI_MASTER_KEY=${config.sops.placeholder."karakeep/meili_master_key"}
  '';

  # Env file mounted into karakeep-meili. Same MEILI_MASTER_KEY so the two
  # sides agree on the auth token.
  sops.templates."karakeep-meili-env".content = ''
    MEILI_MASTER_KEY=${config.sops.placeholder."karakeep/meili_master_key"}
  '';
}
