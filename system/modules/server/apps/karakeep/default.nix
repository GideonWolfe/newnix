{
  imports = [
    # Karakeep container stack (web + chrome + meilisearch)
    ./karakeep.nix
    # Defines the secrets karakeep needs
    ./secrets/secrets_karakeep.nix
    # Restic backup of /data/karakeep to the NAS
    ./karakeep_backup.nix
  ];
}
