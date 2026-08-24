{
  imports = [
    # Immich service stack (server + ML + redis + postgres)
    ./immich.nix
    # Defines the secrets Immich needs
    ./secrets/secrets_immich.nix
    # Restic backup of Immich data to the NAS
    ./immich_backup.nix
  ];
}
