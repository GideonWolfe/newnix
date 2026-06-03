{
  imports = [
    # FreshRSS container service
    ./freshrss.nix
    # Sops secrets + env-file template consumed by freshrss.nix
    ./secrets/secrets_freshrss.nix
  ];
}
