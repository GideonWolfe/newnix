{config, ... }:
{
    # Dell XPS 15 9510 laptop. Joins the LAN over WiFi and tunnels home through
    # WireGuard (peer 10.0.0.4 on the router's VPN network).
    resource."netbox_device"."ares" = {
        name = "ares";
        device_type_id = "\${netbox_device_type.dell_xps_15_9510.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.workstation.id}";
        status = "active";
        comments = "Dell XPS 15 9510 laptop. Reaches home services remotely over WireGuard.";
    };

    # WiFi interface for the LAN
    resource."netbox_device_interface"."ares_wlan0" = {
        name = "wlp0s20f3";
        device_id = "\${netbox_device.ares.id}";
        type = "ieee802.11ax";
        mac_address = "AC:74:B1:88:0C:AC";
    };

    # WireGuard tunnel interface
    resource."netbox_device_interface"."ares_wg0" = {
        name = "wg0";
        device_id = "\${netbox_device.ares.id}";
        type = "virtual";
        description = "WireGuard VPN. Public key: ${config.custom.world.hosts.ares.wireguard.public_key}";
    };

    # LAN IP on the WiFi interface (primary)
    resource."netbox_ip_address"."ares_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.ares.ip}/24";
        device_interface_id = "\${netbox_device_interface.ares_wlan0.id}";
        status = "active";
    };
    resource."netbox_device_primary_ip"."ares_ip_primary" = {
        device_id = "\${netbox_device.ares.id}";
        ip_address_id = "\${netbox_ip_address.ares_ip1.id}";
    };

    # WireGuard VPN IP on the tunnel interface
    resource."netbox_ip_address"."ares_wg_ip" = {
        ip_address = "${builtins.toString config.custom.world.hosts.ares.wireguard.ip}/24";
        device_interface_id = "\${netbox_device_interface.ares_wg0.id}";
        status = "active";
        description = "WireGuard tunnel address on the router's VPN network";
    };
}
