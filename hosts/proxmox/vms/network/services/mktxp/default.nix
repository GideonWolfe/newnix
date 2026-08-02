{
    imports = [
        # The mktxp exporter service definition
        ./mktxp.nix
        # Reuse the same router credentials as the base mikrotik exporter.
        # Nix dedupes imports by path, so importing this alongside the base
        # exporter is safe.
        ../mikrotik-prometheus-exporter/secrets/secrets_mikrotik.nix
    ];
}
