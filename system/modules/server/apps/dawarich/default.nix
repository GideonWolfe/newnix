{
  imports = [
    # Dawarich container stack (app + sidekiq + postgres + redis)
    ./dawarich.nix
    # Defines the secrets dawarich needs
    ./secrets/secrets_dawarich.nix
    # Daily pg_dumpall + restic backup to the NAS
    ./dawarich_backup.nix
    # Daily GPX export of raw points to the NAS
    ./dawarich_gpx_export.nix
  ];
}
