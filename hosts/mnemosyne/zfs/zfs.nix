{
    imports = [
        # ZFS scrubbing configuration
        #./zfs-scrubbing.nix

        # ZFS snapshot configuration
        #./zfs-snapshots.nix

        # ZFS replication configuration
        #./zfs-replication.nix

        # ZFS Monitoring configuration
        #./zfs-monitoring.nix
    ];
    # boot.zfs = {
    #     # Enable ZFS support
    #     enabled = true;
    #     # Configure the main ZFS pool
    #     # pools = {
    #     #     "vault" = {
    #     #         # TODO fill in with absolute path
    #     #         # Should this be mounted with FSTAB first or something?
    #     #         #devNodes = ;
    #     #     };
    #     # };
    # };
    # Give the system ZFS support so we can use it for our NAS storage pool
    boot.supportedFilesystems = [ "zfs" ];
    # Needs a unique hostId for ZFS to work properly
    networking.hostId = "c70ed63d"; # generated with head -c 8 /etc/machine-id
    # Make sure the "tank" pool is imported at boot
    boot.zfs.extraPools = ["tank"]; 
}