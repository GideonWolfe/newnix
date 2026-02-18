{lib, ...}:
{
    sops = {
        # Tell SOPS to get secrets from the VM specific file in the same dir
        defaultSopsFile = lib.mkForce ./secrets_media.yaml;
        secrets = {
            "nzbget/user" = { owner = "gideon"; };
        };
    };
}