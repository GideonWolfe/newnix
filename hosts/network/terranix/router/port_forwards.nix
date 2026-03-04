{
    resource."routeros_ip_firewall_nat"."http_to_athena" = {
        chain        = "dstnat";
        action       = "dst-nat";
        protocol     = "tcp";
        dst_port     = "80";
        in_interface = "bridge";
        to_addresses = "\${routeros_ip_dhcp_server_lease.athena.address}";
        to_ports     = "80";
        comment      = "Port forward HTTP to Athena";
        provider    = "routeros.router";
    };
    resource."routeros_ip_firewall_nat"."https_to_athena" = {
        chain        = "dstnat";
        action       = "dst-nat";
        protocol     = "tcp";
        dst_port     = "443";
        in_interface = "bridge";
        to_addresses = "\${routeros_ip_dhcp_server_lease.athena.address}";
        to_ports     = "443";
        comment      = "Port forward HTTPS to Athena";
        provider    = "routeros.router";
    };
}