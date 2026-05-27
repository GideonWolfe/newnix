{
  imports = [
    # Headless Obsidian Sync service
    ./obsidian-headless.nix
    # sops secrets used to bootstrap the sync
    ./secrets/secrets_obsidian-headless.nix
  ];
}
