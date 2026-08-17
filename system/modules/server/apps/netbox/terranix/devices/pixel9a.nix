{config, ... }:
{
    # Pixel 9a Android phone. Joins the LAN over WiFi and tunnels home through
    # WireGuard (peer 10.0.0.2 on the router's VPN network).
    resource."netbox_device"."pixel9a" = {
        name = "Pixel 9a";
        device_type_id = "\${netbox_device_type.pixel_9a.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.handheld.id}";
        status = "active";
        comments = "Android phone. Reaches home services remotely over WireGuard.";
    };

    # WiFi interface for the LAN
    resource."netbox_device_interface"."pixel9a_wlan0" = {
        name = "wlan0";
        device_id = "\${netbox_device.pixel9a.id}";
        type = "ieee802.11ax";
    };

    # WireGuard tunnel interface
    resource."netbox_device_interface"."pixel9a_wg0" = {
        name = "wg0";
        device_id = "\${netbox_device.pixel9a.id}";
        type = "virtual";
        description = "WireGuard VPN. Public key: ${config.custom.world.hosts.pixel9a.wireguard.public_key}";
    };

    # LAN IP on the WiFi interface (primary)
    resource."netbox_ip_address"."pixel9a_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.pixel9a.ip}/24";
        device_interface_id = "\${netbox_device_interface.pixel9a_wlan0.id}";
        status = "active";
    };
    resource."netbox_device_primary_ip"."pixel9a_ip_primary" = {
        device_id = "\${netbox_device.pixel9a.id}";
        ip_address_id = "\${netbox_ip_address.pixel9a_ip1.id}";
    };

    # WireGuard VPN IP on the tunnel interface
    resource."netbox_ip_address"."pixel9a_wg_ip" = {
        ip_address = "${builtins.toString config.custom.world.hosts.pixel9a.wireguard.ip}/24";
        device_interface_id = "\${netbox_device_interface.pixel9a_wg0.id}";
        status = "active";
        description = "WireGuard tunnel address on the router's VPN network";
    };
}
