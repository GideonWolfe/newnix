{
    imports = [
        # Paperless-ngx service configuration
        ./paperless.nix
        # Defines the secrets Paperless-ngx needs
        ./secrets/secrets_paperless.nix
    ];
}