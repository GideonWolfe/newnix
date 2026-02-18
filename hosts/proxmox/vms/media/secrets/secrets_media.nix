{lib, config, ...}:
{
    sops = {
        # Tell SOPS to get secrets from the VM specific file in the same dir
        defaultSopsFile = lib.mkForce ./secrets_media.yaml;
        secrets = {
            "eweka/username" = { owner = "gideon"; };
            "eweka/password" = { owner = "gideon"; };
            "newshosting/username" = { owner = "gideon"; };
            "newshosting/password" = { owner = "gideon"; };
        };
    };
}
