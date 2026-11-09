{
  imports = [
    # Tududi container service
    ./tududi.nix
    # SOPS-managed database and bootstrap credentials
    ./secrets/secrets_tududi.nix
    # Daily PostgreSQL dump, uploads, and app exports to the NAS
    ./tududi_backup.nix
  ];
}
