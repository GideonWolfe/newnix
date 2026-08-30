{config, ... }:
{
    # Poseidon — Lenovo ThinkPad T490 running NixOS. A "beater" grab-and-go
    # laptop for work on the move: joins networks over Wi-Fi and tunnels home
    # through WireGuard (peer 10.0.0.1 on the router's VPN network).
    resource."netbox_device"."poseidon" = {
        name = "poseidon";
        device_type_id = "\${netbox_device_type.lenovo_thinkpad_t490.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.workstation.id}";
        status = "active";
        comments = "Lenovo ThinkPad T490 (NixOS). On-the-go work laptop; reaches home services remotely over WireGuard.";
    };

    # USB-C power (65W ThinkPad adapter)
    resource."netbox_device_power_port"."poseidon_power1" = {
        name = "USB-C Power";
        device_id = "\${netbox_device.poseidon.id}";
        type = "usb-c";
        maximum_draw = 65;
    };

    # Intel Wireless-AC 9560 (Wi-Fi 5 / 802.11ac) — primary link for a
    # grab-and-go laptop
    resource."netbox_device_interface"."poseidon_wlan0" = {
        name = "wlan0";
        device_id = "\${netbox_device.poseidon.id}";
        type = "ieee802.11ac";
        description = "Intel Wireless-AC 9560";
    };

    # Onboard Gigabit Ethernet (Intel I219-V) — occasional wired link
    resource."netbox_device_interface"."poseidon_eth0" = {
        name = "eth0";
        device_id = "\${netbox_device.poseidon.id}";
        type = "1000base-t";
        description = "Onboard Intel I219-V Gigabit Ethernet (rarely used)";
    };

    # WireGuard tunnel interface — spoke on the wg-home mesh
    resource."netbox_device_interface"."poseidon_wg0" = {
        name = "wg0";
        device_id = "\${netbox_device.poseidon.id}";
        type = "virtual";
        description = "WireGuard VPN. Public key: ${config.custom.world.hosts.poseidon.wireguard.public_key}";
    };

    # LAN IP on the Wi-Fi interface (primary)
    resource."netbox_ip_address"."poseidon_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.poseidon.ip}/24";
        device_interface_id = "\${netbox_device_interface.poseidon_wlan0.id}";
        status = "active";
    };
    resource."netbox_device_primary_ip"."poseidon_ip_primary" = {
        device_id = "\${netbox_device.poseidon.id}";
        ip_address_id = "\${netbox_ip_address.poseidon_ip1.id}";
    };

    # WireGuard VPN IP on the tunnel interface
    resource."netbox_ip_address"."poseidon_wg_ip" = {
        ip_address = "${builtins.toString config.custom.world.hosts.poseidon.wireguard.ip}/24";
        device_interface_id = "\${netbox_device_interface.poseidon_wg0.id}";
        status = "active";
        description = "WireGuard tunnel address on the router's VPN network";
    };
}
