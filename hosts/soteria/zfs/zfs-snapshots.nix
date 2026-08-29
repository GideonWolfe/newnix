{
    services.sanoid = {
        enable = true;
        # Make Sanoid give us more info
        extraArgs = ["--verbose"];
        templates = {
            # This is a custom template that matches my desired snapshot retention policy
            "media" = {
                # Bulk media: avoid churny hourlies, keep a light long-tail
                hourly = 0; # No hourly snapshots
                daily = 0; # Take no daily snapshots
                weekly = 2; # Take one snapshot per week, keep the last 2 weeks
                monthly = 6; # Take one snapshot a month, keep the last 6 months
                yearly = 0; # No yearly snapshots
                autosnap = true; # Automatically take snapshots
                autoprune = true; # Automatically prune old snapshots
            };
            "vm_images" = {
                hourly = 0; # No hourly snapshots
                daily = 0; # No daily snapshots
                weekly = 0; # No weekly snapshots
                monthly = 1; # Take one snapshot per month, keep the last 1 month
                yearly = 2; # Take one snapshot per year, keep the last 2 years
                autosnap = true; # Automatically take snapshots
                autoprune = true; # Automatically prune old snapshots
            };
            "vm_backups" = {
                hourly = 0; # No hourly snapshots
                daily = 3; # Take one snapshot per day, keep the last 3 days
                weekly = 1; # Take one snapshot per week, keep the last 1 week
                monthly = 1; # Take one snapshot per month, keep the last 1 month
                yearly = 1; # Take one snapshot per year, keep the last 1 year
                autosnap = true; # Automatically take snapshots
                autoprune = true; # Automatically prune old snapshots
            };
            "service_backups" = {
                hourly = 0; # No hourly snapshots
                daily = 7; # Take one snapshot per day, keep the last 7 days
                weekly = 4; # Take one snapshot per week, keep the last 4 weeks
                monthly = 4; # Take one snapshot per month, keep the last 4 months
                yearly = 1; # Take one snapshot per year, keep the last 1 year
                autosnap = true; # Automatically take snapshots
                autoprune = true; # Automatically prune old snapshots
            };
            "bucket" = {
                hourly = 0; # No hourly snapshots
                daily = 1; # Take one snapshot per day, keep the last 1 day
                weekly = 1; # Take one snapshot per week, keep the last 1 week
                monthly = 1; # Take one snapshot per month, keep the last 1 month
                yearly = 0; # Take one snapshot per year, keep the last 1 year
                autosnap = true; # Automatically take snapshots
                autoprune = true; # Automatically prune old snapshots
            };
            "personal" = {
                hourly = 2; # Take one snapshot per hour, keep the last 2 hours
                daily = 3; # Take one snapshot per day, keep the last 3 days
                weekly = 4; # Take one snapshot per week, keep the last 4 weeks
                monthly = 4; # Take one snapshot per month, keep the last 4 months
                yearly = 1; # Take one snapshot per year, keep the last 1 year
                autosnap = true; # Automatically take snapshots
                autoprune = true; # Automatically prune old snapshots
            };
        };
        # This is where we configure the per-dataset snapshot settings
        # Dataset names should match what "zfs list" shows, not literal filepaths
        datasets = {
            # Making individual snapshot targets lets me roll back granularly
            # As well as change snapshot options granularly in the future
            "tank/media/books".useTemplate = [ "media" ];
            "tank/media/movies".useTemplate = [ "media" ];
            "tank/media/tv".useTemplate = [ "media" ];
            "tank/media/music".useTemplate = [ "media" ];

            "tank/infra/vms/images".useTemplate    = [ "vm_images" ];
            "tank/infra/vms/templates".useTemplate = [ "vm_images" ];
            "tank/infra/vms/backups".useTemplate   = [ "vm_backups" ];

            "tank/infra/services".useTemplate = [ "service_backups" ];

            # AI model/prompt library on its own dataset (see llama-swap.nix)
            "tank/infra/ai".useTemplate = [ "service_backups" ];

            "tank/bucket".useTemplate = [ "bucket" ];

            "tank/personal".useTemplate = [ "personal" ];
        };
    };
}
