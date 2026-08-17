{config, ... }:
{
    # Retroid Pocket 6 Android handheld. Joins the LAN over WiFi and tunnels
    # home through WireGuard (peer 10.0.0.3 on the router's VPN network).
    resource."netbox_device"."retroidpocket6" = {
        name = "Retroid Pocket 6";
        device_type_id = "\${netbox_device_type.retroid_pocket6.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.handheld.id}";
        status = "active";
        comments = "Android gaming handheld. Reaches home services remotely over WireGuard.";
    };

    # WiFi interface for the LAN
    resource."netbox_device_interface"."retroidpocket6_wlan0" = {
        name = "wlan0";
        device_id = "\${netbox_device.retroidpocket6.id}";
        type = "ieee802.11ax";
    };

    # WireGuard tunnel interface
    resource."netbox_device_interface"."retroidpocket6_wg0" = {
        name = "wg0";
        device_id = "\${netbox_device.retroidpocket6.id}";
        type = "virtual";
        description = "WireGuard VPN. Public key: ${config.custom.world.hosts.retroidpocket6.wireguard.public_key}";
    };

    # LAN IP on the WiFi interface (primary)
    resource."netbox_ip_address"."retroidpocket6_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.retroidpocket6.ip}/24";
        device_interface_id = "\${netbox_device_interface.retroidpocket6_wlan0.id}";
        status = "active";
    };
    resource."netbox_device_primary_ip"."retroidpocket6_ip_primary" = {
        device_id = "\${netbox_device.retroidpocket6.id}";
        ip_address_id = "\${netbox_ip_address.retroidpocket6_ip1.id}";
    };

    # WireGuard VPN IP on the tunnel interface
    resource."netbox_ip_address"."retroidpocket6_wg_ip" = {
        ip_address = "${builtins.toString config.custom.world.hosts.retroidpocket6.wireguard.ip}/24";
        device_interface_id = "\${netbox_device_interface.retroidpocket6_wg0.id}";
        status = "active";
        description = "WireGuard tunnel address on the router's VPN network";
    };
}
