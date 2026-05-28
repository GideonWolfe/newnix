{
  imports = [
    # TubeArchivist container stack (TA + Elasticsearch + Redis)
    ./tubearchivist.nix
    # Secrets (TA admin password + Elasticsearch password)
    ./secrets/secrets_tubearchivist.nix
    # Restic backup of /data/tubearchivist to the NAS
    ./tubearchivist_backup.nix
  ];
}
