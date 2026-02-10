{
    # Configure ZFS scrubbing
    services.zfs = {
        autoScrub = {
            enable = true;
            # TODO finalize once pool name is decided
            # this should probably be a variable anyways
            #pools  = [];
            interval = "monthly";
        };
    };
}