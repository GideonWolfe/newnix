{
    # We want to expose our ZFS pools over NFS
    services.nfs = {
        # Enable the NFS server
        server = {
            enable = true;
        };

        # Plug in the NFS settings
        settings = {};
    };
}