{
    imports = [
        # ZFS scrubbing configuration
        ./zfs-scrubbing.nix

        # ZFS snapshot configuration
        ./zfs-snapshots.nix

        # ZFS replication configuration
        ./zfs-replication.nix

        # ZFS Monitoring configuration
        ./zfs-monitoring.nix
    ];
    boot.zfs = {
        # Enable ZFS support
        enabled = true;
        # Configure the main ZFS pool
        pools = {
            "vault" = {
                # TODO fill in with absolute path
                # Should this be mounted with FSTAB first or something?
                #devNodes = ;
            };
        };
    };
}