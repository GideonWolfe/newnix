{
  imports = [
    # Dawarich container stack (app + sidekiq + postgres + redis)
    ./dawarich.nix
    # Defines the secrets dawarich needs
    ./secrets/secrets_dawarich.nix
  ];
}
