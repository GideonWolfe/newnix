{
    imports = [
        # Mealie service configuration
        ./mealie.nix
        # Restic backup of Mealie data to the NAS
        ./mealie_backup.nix
        # Defines the secrets Mealie needs
        ./secrets/secrets_mealie.nix
    ];
}