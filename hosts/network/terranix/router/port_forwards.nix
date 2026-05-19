{ config, ... }:
{
    # The ingress VM has a static IP (no DHCP lease), so reference the world IP
    # directly. The VM can float between Proxmox nodes via HA while keeping
    # this IP, so the forward keeps resolving regardless of host.
    resource."routeros_ip_firewall_nat"."http_to_ingress" = {
        chain        = "dstnat";
        action       = "dst-nat";
        protocol     = "tcp";
        dst_port     = "80";
        in_interface_list = "WAN";
        to_addresses = "${config.custom.world.hosts.proxmox.vms.ingress_vm.ip}";
        to_ports     = "80";
        comment      = "Port forward HTTP to Ingress VM";
        provider    = "routeros.router";
    };
    resource."routeros_ip_firewall_nat"."https_to_ingress" = {
        chain        = "dstnat";
        action       = "dst-nat";
        protocol     = "tcp";
        dst_port     = "443";
        in_interface_list = "WAN";
        to_addresses = "${config.custom.world.hosts.proxmox.vms.ingress_vm.ip}";
        to_ports     = "443";
        comment      = "Port forward HTTPS to Ingress VM";
        provider    = "routeros.router";
    };
}
