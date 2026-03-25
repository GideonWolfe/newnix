{lib, config, ...}:
{
    sops = {
        defaultSopsFile = lib.mkForce ./secrets_mealie.yaml;
        secrets = {
            "mealie/env" = {};
        };
    };
}
