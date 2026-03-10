{ config, ... }:
{
  resource."routeros_ip_dhcp_server_lease"."poseidon" = {
    mac_address = "6C:6E:07:05:36:6E";
    address = "${config.custom.world.hosts.poseidon.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Poseidon (Thinkpad T490)";
  };

  resource."routeros_ip_dhcp_server_lease"."hades" = {
    mac_address = "2C:f0:5D:59:89:6A";
    address = "${config.custom.world.hosts.hades.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Hades (Main Desktop)";
  };

  resource."routeros_ip_dhcp_server_lease"."athena" = {
    mac_address = "D8:43:AE:90:5A:D1";
    address = "${config.custom.world.hosts.athena.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Athena (Tower)";
  };

  resource."routeros_ip_dhcp_server_lease"."pixel9a" = {
    mac_address = "FE:CC:90:E4:15:C1";
    address = "${config.custom.world.hosts.pixel9a.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Pixel 9A";
  };

  resource."routeros_ip_dhcp_server_lease"."mnemosyne" = {
    mac_address = "6C:1F:F7:A9:A5:FB";
    address = "${config.custom.world.hosts.mnemosyne.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Mnemosyne (NAS)";
  };

  resource."routeros_ip_dhcp_server_lease"."pvenet" = {
    mac_address = "7C:83:34:B9:A4:AF";
    address = "${config.custom.world.hosts.proxmox.nodes.pvenet.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Network Rack PVE Node";
  };

  resource."routeros_ip_dhcp_server_lease"."pve1" = {
    mac_address = "00:23:24:c9:76:48";
    address = "${config.custom.world.hosts.proxmox.nodes.pve1.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Compute Rack PVE Node 1";
  };

  resource."routeros_ip_dhcp_server_lease"."pve2" = {
    mac_address = "00:23:24:b5:5b:81";
    address = "${config.custom.world.hosts.proxmox.nodes.pve2.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Compute Rack PVE Node 2";
  };

  resource."routeros_ip_dhcp_server_lease"."pve3" = {
    mac_address = "00:23:24:a8:4d:d3";
    address = "${config.custom.world.hosts.proxmox.nodes.pve3.ip}";
    server = "defconf";
    provider = "routeros.router";
    comment = "Compute Rack PVE Node 3";
  };
}

