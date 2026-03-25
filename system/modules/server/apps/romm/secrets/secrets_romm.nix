{lib, config, ...}:
{
    sops = {
        defaultSopsFile = lib.mkForce ./secrets_romm.yaml;
        secrets = {
            "romm-db/db_user" = {};
            "romm-db/db_pass" = {};
            "romm/auth_secret_key" = {};
            "screenscraper/username" = {};
            "screenscraper/password" = {};
            "steamgriddb/api_key" = {};
        };
    };

    # https://docs.romm.app/4.5.0/Getting-Started/Quick-Start-Guide/#build
    sops.templates."romm-env".content = ''
        DB_USER=${config.sops.placeholder."romm-db/db_user"}
        DB_PASSWD=${config.sops.placeholder."romm-db/db_pass"}
        ROMM_AUTH_SECRET_KEY=${config.sops.placeholder."romm/auth_secret_key"}
        SCREENSCRAPER_USER=${config.sops.placeholder."screenscraper/username"}
        SCREENSCRAPER_PASSWORD=${config.sops.placeholder."screenscraper/password"}
        STEAMGRIDDB_API_KEY=${config.sops.placeholder."steamgriddb/api_key"}
    '';

    sops.templates."romm-db-env".content = ''
        MARIADB_USER=${config.sops.placeholder."romm-db/db_user"}
        MARIADB_PASSWORD=${config.sops.placeholder."romm-db/db_pass"}
        MARIADB_ROOT_PASSWORD=${config.sops.placeholder."romm-db/db_pass"}
    '';
}
