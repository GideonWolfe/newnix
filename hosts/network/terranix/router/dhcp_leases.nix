{config, ... }:
{
  resource."routeros_ip_dhcp_server_lease"."poseidon" = {
    mac_address = "6C:6E:07:05:36:6E";
    #address = "192.168.88.201";
    address = "${config.custom.world.hosts.poseidon.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Poseidon (Thinkpad T490)";
  };

  resource."routeros_ip_dhcp_server_lease"."athena" = {
    mac_address = "D8:43:AE:90:5A:D1";
    #address = "192.168.88.202";
    address = "${config.custom.world.hosts.athena.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Athena";
  };

  resource."routeros_ip_dhcp_server_lease"."pixel9a" = {
    mac_address = "FE:CC:90:E4:15:C1";
    #address = "192.168.88.203";
    address = "${config.custom.world.hosts.pixel9a.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Pixel 9A";
  };
}