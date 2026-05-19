{ config, ... }:
{

    # Define the router
    services.traefik.dynamicConfigOptions.http.routers.mealie = {
        entryPoints = [ "https" ];
        rule = "Host(`${config.custom.world.services.mealie.domain}`)";
        service = "mealie";
        tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
        tls.certResolver = "myresolver";
    };

    # Define the service
    services.traefik.dynamicConfigOptions.http.services.mealie = {
        loadBalancer = {
            passHostHeader = true;
            servers = [{ url = "http://${config.custom.world.services.mealie.ip}:${builtins.toString config.custom.world.services.mealie.port}"; }];
        };
    };
}