# Allows me to get SSL certs for my services
{ config, ... }:
{
    services.traefik.staticConfigOptions.certificatesResolvers.myresolver.acme = {
        email = "gideon@gideonwolfe.xyz";
        storage = "/var/lib/traefik/gideonwolfe.json";
        # Wildcard certs require DNS-01. TLS-ALPN-01 (tlsChallenge) cannot
        # issue *.gideonwolfe.xyz, so use DigitalOcean DNS exclusively.
        dnsChallenge = {
            provider = "digitalocean";
            # Resolve TXT records against public DNS so we don't get tripped
            # up by any local split-horizon DNS while waiting for propagation.
            resolvers = [ "1.1.1.1:53" "8.8.8.8:53" ];
        };
    };

    # Contains DO API Key for ACME DNS challenge
    services.traefik.environmentFiles = [ config.sops.secrets."traefik/env".path ];
}