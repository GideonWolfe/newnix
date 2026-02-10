{
    # We want to expose our ZFS pools over NFS
    services.nfs = {
        # Enable the NFS server
        server = {
            enable = true;
        };

        # NOTE: NFS settings shouldn't actually be required here.
        # https://wiki.nixos.org/wiki/ZFS#NFS_share
        # When we created the datasets with the "sharenfs" option, 
        # that should have automatically configured the NFS exports for us.
        # Plug in the NFS settings
        #settings = {};
    };
    # We won't be able to connect from a client unless we punch a hole in the FW
    networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 20048]; # NFS
    networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 20048]; # NFS
}