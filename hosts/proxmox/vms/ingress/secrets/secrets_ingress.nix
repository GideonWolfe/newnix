{lib, config, ...}:
{
    sops = {
        # Tell SOPS to get secrets from the VM specific file in the same dir
        defaultSopsFile = lib.mkForce ./secrets_ingress.yaml;
        secrets = {
            "traefik/env" = {};
        };
    };
}
