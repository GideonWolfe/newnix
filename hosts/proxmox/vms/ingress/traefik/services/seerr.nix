{

    # Define the router
    services.traefik.dynamicConfigOptions.http.routers.seerr = {
        entryPoints = [ "https" "http" ];
        rule = "Host(`${config.custom.world.services.seerr.domain}`)";
        service = "seerr";
        tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
        tls.certResolver = "myresolver";
    };

    # Define the service
    services.traefik.dynamicConfigOptions.http.services.seerr = {
        loadBalancer = {
            passHostHeader = true;
            servers = [{ url = "http://${config.custom.world.services.seerr.ip}:${config.custom.world.services.seerr.port}"; }];
        };
    };
}