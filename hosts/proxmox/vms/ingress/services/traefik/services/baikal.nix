{ config, ... }:
# Traefik router for Baikal (CalDAV/CardDAV server on vm-test).
#
# The actual container lives in
# system/modules/server/apps/baikal/baikal.nix - this file just
# describes how vm-ingress forwards public HTTPS traffic at
# https://${svc.domain} to it.
#
# Pattern matches the other services in this directory (mealie,
# karakeep, etc): one router + one load-balanced backend, TLS via the
# wildcard *.gideonwolfe.xyz cert from acme.
{
    services.traefik.dynamicConfigOptions.http.routers.baikal = {
        entryPoints = [ "https" ];
        rule = "Host(`${config.custom.world.services.baikal.domain}`)";
        service = "baikal";
        tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
        tls.certResolver = "myresolver";
    };

    services.traefik.dynamicConfigOptions.http.services.baikal = {
        loadBalancer = {
            # passHostHeader so baikal sees the public hostname (used
            # for generated principal URLs / .well-known redirects).
            # The famous ckulka/baikal-docker#300 nginx port-stripping
            # bug doesn't fire here: every client request comes in via
            # the default https/:443 entry on dav.gideonwolfe.xyz, so
            # there's no non-default port for nginx to strip.
            passHostHeader = true;
            servers = [{
                url = "http://${config.custom.world.services.baikal.ip}:${builtins.toString config.custom.world.services.baikal.port}";
            }];
        };
    };
}
