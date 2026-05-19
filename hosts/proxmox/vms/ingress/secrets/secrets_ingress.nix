{lib, config, ...}:
{
    sops = {
        # Tell SOPS to get secrets from the VM specific file in the same dir
        defaultSopsFile = lib.mkForce ./secrets_ingress.yaml;
        secrets = {
            # Read by traefik (envsubst on the static config) — needs to be
            # readable as the traefik service user.
            "traefik/env" = {
                owner = "traefik";
                group = "traefik";
                mode = "0400";
            };
            # Read by the crowdsec-bouncer plugin running inside traefik.
            "crowdsec/api_key" = {
                owner = "traefik";
                group = "traefik";
                mode = "0400";
            };
        };
    };
}
