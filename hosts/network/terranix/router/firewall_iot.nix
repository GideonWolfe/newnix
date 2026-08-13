{ ... }:
{
  # Stage B: IoT isolation. Only ONE drop rule (IoT -> LAN); everything else
  # is accept. Rules are placed before the defconf forward drop (*B) and
  # input drop (*5) so they take effect. Ordering within the forward chain is
  # chained via place_before so the established/related and LAN->IoT accepts
  # sit ahead of the IoT->LAN drop (otherwise replies to LAN-initiated
  # sessions would be dropped).

  # --- Forward chain ---
  # *B = defconf: drop all from WAN not DSTNATed

  # Accept replies to already-allowed sessions (e.g. LAN-initiated -> IoT).
  # Must precede iot_drop_to_lan so return traffic survives.
  resource."routeros_ip_firewall_filter"."iot_forward_established" = {
    chain = "forward";
    action = "accept";
    connection_state = "established,related";
    in_interface = "vlan-iot";
    comment = "IoT: accept established/related";
    place_before = "\${routeros_ip_firewall_filter.iot_lan_to_iot.id}";
    provider = "routeros.router";
  };

  # LAN (and multi-homed Home Assistant) may initiate to IoT devices.
  resource."routeros_ip_firewall_filter"."iot_lan_to_iot" = {
    chain = "forward";
    action = "accept";
    in_interface_list = "LAN";
    out_interface = "vlan-iot";
    comment = "IoT: allow LAN -> IoT";
    place_before = "\${routeros_ip_firewall_filter.iot_drop_to_lan.id}";
    provider = "routeros.router";
  };

  # The isolation rule: IoT devices cannot initiate into the LAN.
  resource."routeros_ip_firewall_filter"."iot_drop_to_lan" = {
    chain = "forward";
    action = "drop";
    in_interface = "vlan-iot";
    out_interface_list = "LAN";
    comment = "IoT: block IoT -> LAN";
    place_before = "\${routeros_ip_firewall_filter.iot_to_wan.id}";
    provider = "routeros.router";
  };

  # IoT devices are allowed out to the internet (defconf srcnat masquerade on
  # WAN provides the NAT).
  resource."routeros_ip_firewall_filter"."iot_to_wan" = {
    chain = "forward";
    action = "accept";
    in_interface = "vlan-iot";
    out_interface_list = "WAN";
    comment = "IoT: allow IoT -> WAN (internet)";
    place_before = "*B"; # defconf: drop all from WAN not DSTNATed
    provider = "routeros.router";
  };

  # --- Input chain ---
  # *5 = defconf: drop all not coming from LAN

  # Allow IoT clients to reach the router for DHCP and DNS only.
  resource."routeros_ip_firewall_filter"."iot_dns_dhcp" = {
    chain = "input";
    action = "accept";
    in_interface = "vlan-iot";
    protocol = "udp";
    dst_port = "53,67";
    comment = "IoT: allow DHCP/DNS to router";
    place_before = "*5"; # defconf: drop all not coming from LAN
    provider = "routeros.router";
  };
}
