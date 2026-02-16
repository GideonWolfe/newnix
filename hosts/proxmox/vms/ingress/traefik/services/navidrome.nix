{

    # Define the router
    services.traefik.dynamicConfigOptions.http.routers.navidrome = {
        entryPoints = [ "https" "http" ];
        rule = "Host(`${config.custom.world.services.navidrome.domain}`)";
        service = "navidrome";
        tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
        tls.certResolver = "myresolver";
    };

    # Define the service
    services.traefik.dynamicConfigOptions.http.services.navidrome = {
        loadBalancer = {
            passHostHeader = true;
            servers = [{ url = "http://${config.custom.world.services.navidrome.ip}:${config.custom.world.services.navidrome.port}"; }];
        };
    };
}