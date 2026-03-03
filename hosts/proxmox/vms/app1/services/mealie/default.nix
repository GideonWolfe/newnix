{
    imports = [
        # Mealie service configuration
        ./mealie.nix
        # Defines the secrets Mealie needs
        ./secrets/secrets_mealie.nix
    ];
}