{lib, config, ...}:
{
    sops = {
        # Tell SOPS to get secrets from the VM specific file in the same dir
        defaultSopsFile = lib.mkForce ./secrets_ingress.yaml;
        secrets = {
            # Read by traefik (envsubst on the static config) — needs to be
            # readable as the traefik service user.
            #
            # `restartUnits` tells sops-nix to bounce traefik whenever the
            # decrypted value of this secret changes between activations.
            # Without this, rotating the value in secrets_ingress.yaml + a
            # rebuild would update /run/secrets/... but leave the old value
            # in traefik's in-memory env (it only reads the file at startup).
            "traefik/env" = {
                owner = "traefik";
                group = "traefik";
                mode = "0400";
                restartUnits = [ "traefik.service" ];
            };
            # Read by the crowdsec-bouncer plugin running inside traefik.
            # Same reasoning as above: the plugin reads `crowdsecLapiKeyFile`
            # exactly once at plugin init. If we rotate the CrowdSec API key
            # without restarting traefik, the plugin keeps presenting the old
            # key to LAPI, gets 403 on every query, and (failing closed)
            # blocks every incoming request.
            "crowdsec/api_key" = {
                owner = "traefik";
                group = "traefik";
                mode = "0400";
                restartUnits = [ "traefik.service" ];
            };
        };
    };
}
