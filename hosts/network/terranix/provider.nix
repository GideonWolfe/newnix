{ config, ... }:
{
  terraform.required_providers.routeros = {
    source = "terraform-routeros/routeros";
    version = "1.99.0";
  };

  # Central state on the NAS (mnemosyne tank/infra/terraform, NFS-mounted at
  # /nas/tank). State survives a bricked deploy host and is ZFS-snapshotted.
  terraform.backend.local.path = "/nas/tank/infra/terraform/network/terraform.tfstate";

  variable."router_username" = { type = "string"; };
  variable."router_password" = { type = "string"; };
  variable."ap_username" = { type = "string"; };
  variable."ap_password" = { type = "string"; };
  variable."router_wireguard_private_key" = { type = "string"; };

  # Define both provider aliases under the same provider name; Terraform/HCL uses alias to distinguish instances.
  provider."routeros" = [
    {
      alias = "router";
      hosturl = "api://192.168.88.1:8728";
      username = "\${var.router_username}";
      password = "\${var.router_password}";
      insecure = true;
    }
    {
      alias = "ap";
      hosturl = "api://192.168.88.2:8728";
      username = "\${var.ap_username}";
      password = "\${var.ap_password}";
      insecure = true;
    }
  ];
}