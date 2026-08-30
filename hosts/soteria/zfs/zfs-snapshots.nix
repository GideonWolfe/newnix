{
    # Snapshot policy on soteria differs fundamentally from mnemosyne.
    #
    # mnemosyne is the SOURCE: its sanoid *creates* snapshots (autosnap=true).
    # soteria is the REPLICA target: syncoid pulls mnemosyne's existing
    # snapshots into tank/backups/* (with --no-sync-snap), so soteria must NOT
    # create its own snapshots there — it only PRUNES what it receives, on a
    # retention that matches the source so both ends hold the same set.
    #
    # Hence every backups/* template is autosnap=false + autoprune=true.
    # tank/pbs is primary data (PBS owns its real retention/GC), so it gets only
    # a light ZFS safety snapshot.
    services.sanoid = {
        enable = true;
        # Make Sanoid give us more info
        extraArgs = ["--verbose"];
        templates = {
            # --- Prune-only templates (mirror mnemosyne's retention so the
            # received snapshots age out identically; autosnap disabled) ---
            "vm_backups" = {
                hourly = 0;
                daily = 3;
                weekly = 1;
                monthly = 1;
                yearly = 1;
                autosnap = false; # replica: do NOT create snapshots here
                autoprune = true; # only prune received snapshots
            };
            "service_backups" = {
                hourly = 0;
                daily = 7;
                weekly = 4;
                monthly = 4;
                yearly = 1;
                autosnap = false;
                autoprune = true;
            };
            "personal" = {
                hourly = 2;
                daily = 3;
                weekly = 4;
                monthly = 4;
                yearly = 1;
                autosnap = false;
                autoprune = true;
            };

            # Prune-only media retention (mirrors mnemosyne's "media").
            "media" = {
                hourly = 0;
                daily = 0;
                weekly = 2;
                monthly = 6;
                yearly = 0;
                autosnap = false; # replica: do NOT create snapshots here
                autoprune = true;
            };

            # --- Light safety snapshot for the PBS datastore. PBS does its own
            # prune/GC/verify; this is just a ZFS-level "oops" net. ---
            "pbs" = {
                hourly = 0;
                daily = 0;
                weekly = 2;
                monthly = 1;
                yearly = 0;
                autosnap = true; # primary data: soteria DOES snapshot this
                autoprune = true;
            };
        };
        # Dataset names match soteria's actual layout (tank/backups/* replicas
        # + tank/pbs), NOT mnemosyne's source datasets.
        datasets = {
            "tank/backups/media/games".useTemplate         = [ "media" ];
            "tank/backups/personal".useTemplate            = [ "personal" ];
            "tank/backups/infra/services".useTemplate      = [ "service_backups" ];
            "tank/backups/infra/vms/backups".useTemplate   = [ "vm_backups" ];

            "tank/pbs".useTemplate = [ "pbs" ];
        };
    };
}
