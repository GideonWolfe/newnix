{
    imports = [
        # Paperless-ngx service configuration
        ./paperless.nix
        # Consistent metadata export and encrypted backups to the NAS
        ./paperless_backup.nix
        # Defines the secrets Paperless-ngx needs
        ./secrets/secrets_paperless.nix
    ];
}