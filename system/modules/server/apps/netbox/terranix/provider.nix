{config, ... }:
{
    # Import Proxmox terraform provider
    terraform = {
        required_providers = {
            netbox = {
                source = "e-breuninger/netbox";
                version = "5.1.0";
            };
        };
        # Central state on the NAS (mnemosyne tank/infra/terraform, NFS-mounted at
        # /nas/tank). State survives a bricked deploy host and is ZFS-snapshotted.
        backend.local.path = "/nas/tank/infra/terraform/netbox/terraform.tfstate";
    };

    variable."netbox_server_url" = {
        type = "string";
    };
    variable."netbox_api_token" = {
        type = "string";
    };

    provider."netbox" = {
        server_url    = "\${var.netbox_server_url}";
        api_token     = "\${var.netbox_api_token}";
        allow_insecure_https = true;
    };
}