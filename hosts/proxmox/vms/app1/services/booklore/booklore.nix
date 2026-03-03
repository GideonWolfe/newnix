{
    virtualisation.oci-containers.containers.booklore = {
        image = "booklore/booklore:2.0.3";
        ports = [ "${config.custom.world.services.booklore.port}:6060" ];
        autoStart = true;
        # https://github.com/booklore-app/booklore?tab=readme-ov-file#step-1-environment-configuration
        environment = {
            USER_ID = "1000";
            GROUP_ID = "100";
            TZ = "America/New_York";
            DATABASE_URL = "jdbc:mariadb://booklore-mariadb:3306/booklore";
            #TODO change depending on mount
            DISK_TYPE="LOCAL";
        };
        volumes = [
            ":/app/data" #TODO
            ":/books" #TODO
            ":/bookdrop" #TODO
        ];
        environmentFiles = [
            config.sops.templates."booklore-env".path
        ];
    };

    virtualisation.oci-containers.containers.booklore-mariadb = {
        image = "lscr.io/linuxserver/mariadb:11.4.5";
        ports = [ "3306:3306" ];
        autoStart = true;
        # https://github.com/booklore-app/booklore?tab=readme-ov-file#step-1-environment-configuration
        environment = {
            PUID = "1000";
            PGID = "100";
            TZ = "America/New_York";
            MYSQL_DATABASE = "booklore";
        };
        volumes = [
            "/data/booklore-mariadb/config:/config"
        ];
        environmentFiles = [
            config.sops.templates."booklore-mariadb-env".path
        ];
    };
}