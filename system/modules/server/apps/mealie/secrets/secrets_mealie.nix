{lib, config, ...}:
{
    sops = {
        secrets = {
            "mealie/env" = { sopsFile = ./secrets_mealie.yaml;};
        };
    };
}
