{
    imports = [
        # ZFS scrubbing configuration
        ./zfs-scrubbing.nix

        # ZFS snapshot configuration
        ./zfs-snapshots.nix

        # ZFS Monitoring configuration
        ./zfs-monitoring.nix

        # ZFS replication configuration (soteria pulls from mnemosyne).
        # Single dataset (tank/personal) first to validate the path.
        ./zfs-replication.nix
    ];

    # Give the system ZFS support so we can use it for our NAS storage pool
    boot.supportedFilesystems = [ "zfs" ];
    # Needs a unique hostId for ZFS to work properly
    networking.hostId = "b8f3a2e1"; # generated with head -c 8 /etc/machine-id
    # Make sure the "tank" pool is imported at boot
    boot.zfs.extraPools = ["tank"]; 
    # https://wiki.nixos.org/wiki/ZFS#Importing_on_boot
    # Even though it auto imports fine now, saving ourselves possible breakage later
    # Make sure ZFS can find the disks for our pool
    boot.zfs.devNodes = "/dev/disk/by-id/"; 
    # Don't force-import an un-exported root pool (new default from 26.11).
    # Safer: a pool left dirty (e.g. after a crash) won't be blindly imported,
    # avoiding data loss if it were ever in use elsewhere.
    boot.zfs.forceImportRoot = false;
}
