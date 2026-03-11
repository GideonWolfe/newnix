{lib, config, ...}:
{
    sops = {
        # Tell SOPS to get secrets from the VM specific file in the same dir
        defaultSopsFile = lib.mkForce ./secrets_mikrotik.yaml;
        secrets = {
            "mikrotik/rb5009/user" = {};
            "mikrotik/rb5009/password" = {};
            "mikrotik/hapax2/user" = {};
            "mikrotik/hapax2/password" = {};
        };
    };
}
