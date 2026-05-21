{lib, config, ...}:
{
    sops = {
        secrets = {
            "mealie/env" = { sopsFile = ./secrets_mealie.yaml;};
            "mealie/restic_password" = { sopsFile = ./secrets_mealie.yaml;};
        };
    };
}
