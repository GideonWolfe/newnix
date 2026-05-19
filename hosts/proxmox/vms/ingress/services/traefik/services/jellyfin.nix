{config, ... }:
{

    # Define the router
    services.traefik.dynamicConfigOptions.http.routers.jellyfin = {
        entryPoints = [ "https" ];
        rule = "Host(`${config.custom.world.services.jellyfin.domain}`)";
        service = "jellyfin";
        tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
        tls.certResolver = "myresolver";
    };

    # Define the service
    services.traefik.dynamicConfigOptions.http.services.jellyfin = {
        loadBalancer = {
            passHostHeader = true;
            servers = [{ url = "http://${config.custom.world.services.jellyfin.ip}:${builtins.toString config.custom.world.services.jellyfin.port}"; }];
        };
    };
}