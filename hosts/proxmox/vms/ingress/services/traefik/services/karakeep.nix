{ config, ... }:
{

    # Define the router
    services.traefik.dynamicConfigOptions.http.routers.karakeep = {
        entryPoints = [ "https" ];
        rule = "Host(`${config.custom.world.services.karakeep.domain}`)";
        service = "karakeep";
        tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
        tls.certResolver = "myresolver";
    };

    # Define the service
    services.traefik.dynamicConfigOptions.http.services.karakeep = {
        loadBalancer = {
            # Karakeep generates absolute URLs for share links / OAuth based on
            # the incoming Host header, so we must forward it unchanged.
            passHostHeader = true;
            servers = [{ url = "http://${config.custom.world.services.karakeep.ip}:${builtins.toString config.custom.world.services.karakeep.port}"; }];
        };
    };
}
