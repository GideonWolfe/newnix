{ config, ... }:
{
  resource."routeros_ip_dns_record"."internal_redirect" = {
    regexp = ".*\\gideonwolfe\\.xyz";
    comment = "Internal gideonwolfe.xyz Redirect";
    type = "A";
    address = "${config.custom.world.hosts.proxmox.vms.vm_ingress.ip}";
    provider = "routeros.router";
  };

}

