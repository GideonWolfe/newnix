{ config, ... }:
let
  iot = config.custom.world.networks.iot;
in
{
  # Stage A: additive IoT VLAN plumbing. A VLAN interface layered on top of
  # the existing defconf bridge picks tagged VLAN frames off it WITHOUT
  # enabling bridge vlan-filtering, so the working LAN/management config is
  # left completely untouched (and this is trivially removable).

  resource."routeros_interface_vlan"."vlan_iot" = {
    name = "vlan-iot";
    interface = "bridge";
    vlan_id = iot.vlan_id;
    provider = "routeros.router";
    comment = "IoT VLAN (untrusted smart-home devices)";
  };

  # Router's gateway address on the IoT subnet.
  resource."routeros_ip_address"."vlan_iot" = {
    address = "${iot.gateway}/24";
    interface = "\${routeros_interface_vlan.vlan_iot.name}";
    provider = "routeros.router";
  };

  # DHCP address pool handed out to IoT devices.
  resource."routeros_ip_pool"."iot" = {
    name = "iot-pool";
    ranges = [ "${iot.dhcp.start}-${iot.dhcp.end}" ];
    provider = "routeros.router";
  };

  resource."routeros_ip_dhcp_server"."iot" = {
    name = "iot-dhcp";
    interface = "\${routeros_interface_vlan.vlan_iot.name}";
    address_pool = "\${routeros_ip_pool.iot.name}";
    provider = "routeros.router";
  };

  # Gateway + DNS advertised to IoT DHCP clients (DNS points at the router).
  resource."routeros_ip_dhcp_server_network"."iot" = {
    address = iot.subnet;
    gateway = iot.gateway;
    dns_server = [ iot.dns ];
    provider = "routeros.router";
  };
}
