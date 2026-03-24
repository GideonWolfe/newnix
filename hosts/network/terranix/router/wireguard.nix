{config, ... }:
{
  resource."routeros_interface_wireguard"."wg0" = {
    name = "wg0";
    listen_port = "${builtins.toString config.custom.world.hosts.router.wireguard.port}";
    provider = "routeros.router";
    private_key = "\${var.router_wireguard_private_key}";
  };

  resource."routeros_ip_address"."wg0" = {
    address = "${config.custom.world.hosts.router.wireguard.ip}/24";
    interface = "\${routeros_interface_wireguard.wg0.name}";
    provider = "routeros.router";
  };


  # Route WireGuard subnet traffic back through wg0 so LAN hosts can reply to VPN clients
  resource."routeros_ip_route"."wg0" = {
    dst_address = config.custom.world.hosts.router.wireguard.subnet;
    gateway = "\${routeros_interface_wireguard.wg0.name}";
    provider = "routeros.router";
  };

  # Accept WireGuard UDP packets arriving from WAN before the default input drop rule
  resource."routeros_ip_firewall_filter"."wg0_wan_input" = {
    chain = "input";
    action = "accept";
    protocol = "udp";
    dst_port = "${builtins.toString config.custom.world.hosts.router.wireguard.port}";
    in_interface_list = "WAN";
    comment = "Allow WireGuard UDP from WAN";
    provider = "routeros.router";
  };

  # Accept WireGuard UDP from LAN clients connecting via the WAN IP (hairpin/NAT loopback)
  resource."routeros_ip_firewall_filter"."wg0_lan_input" = {
    chain = "input";
    action = "accept";
    protocol = "udp";
    dst_port = "${builtins.toString config.custom.world.hosts.router.wireguard.port}";
    in_interface_list = "LAN";
    comment = "Allow WireGuard UDP from LAN (hairpin)";
    provider = "routeros.router";
  };

  # Allow the router itself to be reached from WireGuard peers (e.g. ping 10.0.0.254)
  resource."routeros_ip_firewall_filter"."wg0_input" = {
    chain = "input";
    action = "accept";
    in_interface = "\${routeros_interface_wireguard.wg0.name}";
    comment = "Allow WireGuard peers to reach the router";
    place_before = "\${routeros_ip_firewall_filter.wg0_forward_to_lan.id}";
    provider = "routeros.router";
  };

  # Allow forwarding from WireGuard into the LAN
  resource."routeros_ip_firewall_filter"."wg0_forward_to_lan" = {
    chain = "forward";
    action = "accept";
    in_interface = "\${routeros_interface_wireguard.wg0.name}";
    out_interface_list = "LAN";
    comment = "Allow WireGuard peers to reach LAN";
    provider = "routeros.router";
  };

  # Allow forwarding from LAN back to WireGuard peers (return traffic / initiated from LAN side)
  resource."routeros_ip_firewall_filter"."wg0_forward_from_lan" = {
    chain = "forward";
    action = "accept";
    in_interface_list = "LAN";
    out_interface = "\${routeros_interface_wireguard.wg0.name}";
    comment = "Allow LAN to reach WireGuard peers";
    provider = "routeros.router";
  };

  # Masquerade traffic from WireGuard peers going out to the LAN,
  # so LAN hosts reply to the router rather than needing a route to 10.0.0.0/24
  resource."routeros_ip_firewall_nat"."wg0_masquerade" = {
    chain = "srcnat";
    action = "masquerade";
    src_address = config.custom.world.hosts.router.wireguard.subnet;
    out_interface_list = "LAN";
    comment = "Masquerade WireGuard traffic onto LAN";
    provider = "routeros.router";
  };

  # PEERS 
  resource."routeros_interface_wireguard_peer"."poseidon" = {
    interface = "\${routeros_interface_wireguard.wg0.name}";
    name = "poseidon";
    public_key = config.custom.world.hosts.poseidon.wireguard.public_key;
    allowed_address = [ "${config.custom.world.hosts.poseidon.wireguard.ip}/32" ];
    provider = "routeros.router";
  };

  resource."routeros_interface_wireguard_peer"."pixel9a" = {
    interface = "\${routeros_interface_wireguard.wg0.name}";
    name = "pixel9a";
    public_key = config.custom.world.hosts.pixel9a.wireguard.public_key;
    allowed_address = [ "${config.custom.world.hosts.pixel9a.wireguard.ip}/32" ];
    provider = "routeros.router";
  };
}