{ config, ... }:
{

    # Define the router
    services.traefik.dynamicConfigOptions.http.routers.nextcloud = {
        entryPoints = [ "https" ];
        rule = "Host(`nc.gideonwolfe.xyz`)";
        service = "nextcloud";
        tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
        tls.certResolver = "myresolver";
    };

    # Define the service
    services.traefik.dynamicConfigOptions.http.services.nextcloud = {
        loadBalancer = {
            passHostHeader = true;
            servers = [{ url = "http://192.168.88.201:4343/"; }];
        };
    };
}