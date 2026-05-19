{ config, ... }:
{

    # Define the router
    services.traefik.dynamicConfigOptions.http.routers.romm = {
        entryPoints = [ "https" ];
        rule = "Host(`${config.custom.world.services.romm.domain}`)";
        service = "romm";
        tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
        tls.certResolver = "myresolver";
    };

    # Define the service
    services.traefik.dynamicConfigOptions.http.services.romm = {
        loadBalancer = {
            passHostHeader = true;
            servers = [{ url = "http://${config.custom.world.services.romm.ip}:${builtins.toString config.custom.world.services.romm.port}"; }];
        };
    };
}