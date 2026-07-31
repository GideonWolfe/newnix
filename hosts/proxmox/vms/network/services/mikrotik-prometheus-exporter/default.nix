{
    imports = [
        # The service configuration for the exporter
        ./mikrotik-prometheus-exporter.nix
        # The secrets for the exporter (username/password for each router)
        ./secrets/secrets_mikrotik.nix
    ];
}