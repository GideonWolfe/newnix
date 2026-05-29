{ config, ... }:
{

    # Define the router
    services.traefik.dynamicConfigOptions.http.routers.calibre-web-automated = {
        entryPoints = [ "https" ];
        rule = "Host(`${config.custom.world.services.calibre-web-automated.domain}`)";
        service = "calibre-web-automated";
        tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
        tls.certResolver = "myresolver";
    };

    # Define the service
    services.traefik.dynamicConfigOptions.http.services.calibre-web-automated = {
        loadBalancer = {
            passHostHeader = true;
            servers = [{ url = "http://${config.custom.world.services.calibre-web-automated.ip}:${builtins.toString config.custom.world.services.calibre-web-automated.port}"; }];
        };
    };
}