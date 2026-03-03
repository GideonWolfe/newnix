{lib, config, ...}:
{
    sops = {
        defaultSopsFile = lib.mkForce ./secrets_booklore.yaml;
        secrets = {
            "booklore-mariadb/db_user" = {};
            "booklore-mariadb/db_pass" = {};
        };
    };

    sops.templates."booklore-env".content = ''
        DATABASE_USER=${config.sops.placeholder."booklore-mariadb/db_user"}
        DATABASE_PASSWORD=${config.sops.placeholder."booklore-mariadb/db_pass"}
    '';

    sops.templates."booklore-mariadb-env".content = ''
        MYSQL_USER=${config.sops.placeholder."booklore-mariadb/db_user"}
        MYSQL_PASSWORD=${config.sops.placeholder."booklore-mariadb/db_pass"}
        MYSQL_ROOT_PASSWORD=${config.sops.placeholder."booklore-mariadb/db_pass"}
    '';
}
