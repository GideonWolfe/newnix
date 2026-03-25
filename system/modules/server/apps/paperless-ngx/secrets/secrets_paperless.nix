{lib, config, ...}:
{
    sops = {
        defaultSopsFile = lib.mkForce ./secrets_paperless.yaml;
        secrets = {
            "paperless/admin_pass" = {};
        };
    };
}
