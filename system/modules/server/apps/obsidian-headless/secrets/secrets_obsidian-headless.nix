{lib, config, ...}:
{
    sops = {
        secrets = {
            # Account credentials for the Obsidian Sync service
            "obsidian/email"          = { sopsFile = ./secrets_obsidian.yaml; };
            "obsidian/password"       = { sopsFile = ./secrets_obsidian.yaml; };

            # Remote vault name (or ID) to bind the local directory to
            "obsidian/vault_name"     = { sopsFile = ./secrets_obsidian.yaml; };

            # End-to-end encryption password for the vault. For
            # standard-encrypted vaults, set this to an empty string in
            # the sops file (the bootstrap script handles that case).
            "obsidian/e2ee_password"  = { sopsFile = ./secrets_obsidian.yaml; };

            # Used by an out-of-band restic backup of the vault directory
            "obsidian/restic_password" = { sopsFile = ./secrets_obsidian.yaml; };
        };
    };
}
