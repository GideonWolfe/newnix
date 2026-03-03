# Allows me to get SSL certs for my services
{
    services.traefik.staticConfigOptions.certificatesResolvers.myresolver.acme = {
        email = "gideon@gideonwolfe.xyz";
        storage = "/var/lib/traefik/gideonwolfe.json";
        tlsChallenge = true;
        dnsChallenge = { provider = "digitalocean"; };
    };

    # Contains DO API Key for ACME DNS challenge
    services.traefik.environmentFiles = [ config.sops.secrets."traefik/env".path ];
}