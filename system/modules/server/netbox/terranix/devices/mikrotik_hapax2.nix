{config, ... }:
{
    # Define the device
    resource."netbox_device"."mikrotik_hapax2" = {
        name = "MikroTik hAP ax2";
        device_type_id = "\${netbox_device_type.mikrotik_hapax2.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.access_point.id}";
        rack_id = "\${netbox_rack.home_network_rack.id}";
        rack_position = 3;
        rack_face = "front";
        status = "active";
        comments = "[Product Page](https://mikrotik.com/product/hap_ax2)";
    };

    # Define the device's power port (DC barrel) and PoE-in on ether1
    resource."netbox_device_power_port"."mikrotik_hapax2_power1" = {
        name = "DC IN";
        device_id = "\${netbox_device.mikrotik_hapax2.id}";
        type = "dc-terminal";
        maximum_draw = 24;
    };

    resource."netbox_device_interface"."mikrotik_hapax2_ether1" = {
        name = "ether1";
        label = "1";
        device_id = "\${netbox_device.mikrotik_hapax2.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_hapax2_ether2" = {
        name = "ether2";
        label = "2";
        device_id = "\${netbox_device.mikrotik_hapax2.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_hapax2_ether3" = {
        name = "ether3";
        label = "3";
        device_id = "\${netbox_device.mikrotik_hapax2.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_hapax2_ether4" = {
        name = "ether4";
        label = "4";
        device_id = "\${netbox_device.mikrotik_hapax2.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_hapax2_ether5" = {
        name = "ether5";
        label = "5";
        device_id = "\${netbox_device.mikrotik_hapax2.id}";
        type = "1000base-t";
    };

    # Dual-band Wi-Fi radios (802.11ax)
    resource."netbox_device_interface"."mikrotik_hapax2_wlan24" = {
        name = "wlan24";
        device_id = "\${netbox_device.mikrotik_hapax2.id}";
        type = "ieee802.11ax";
        description = "2.4 GHz";
    };
    resource."netbox_device_interface"."mikrotik_hapax2_wlan5" = {
        name = "wlan5";
        device_id = "\${netbox_device.mikrotik_hapax2.id}";
        type = "ieee802.11ax";
        description = "5 GHz";
    };
}