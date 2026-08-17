{config, ... }:
{
    # SLZB-06MU Zigbee coordinator. Trusted infra on the main LAN (NOT the IoT
    # VLAN); Home Assistant reaches its serial port over ser2net (tcp 6638).
    resource."netbox_device"."slzb06" = {
        name = "SLZB-06MU Zigbee Coordinator";
        device_type_id = "\${netbox_device_type.slzb06mu.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.iot_coordinator.id}";
        status = "active";
        comments = "[SLZB-06MU Product Page](https://smlight.tech/product/slzb-06mu/). Ethernet/PoE Zigbee coordinator; serial exposed to Home Assistant via ser2net on tcp 6638.";
    };

    # Ethernet (PoE) uplink to the LAN
    resource."netbox_device_interface"."slzb06_eth0" = {
        name = "eth0";
        device_id = "\${netbox_device.slzb06.id}";
        type = "100base-tx";
    };

    # Onboard WiFi radio (failover uplink; ethernet/PoE is primary)
    resource."netbox_device_interface"."slzb06_wlan0" = {
        name = "wlan0";
        device_id = "\${netbox_device.slzb06.id}";
        type = "ieee802.11ac";
        description = "Onboard WiFi failover uplink; ethernet/PoE is the primary path";
    };

    # Assign the LAN IP
    resource."netbox_ip_address"."slzb06_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.slzb06.ip}/24";
        device_interface_id = "\${netbox_device_interface.slzb06_eth0.id}";
        status = "active";
    };
    resource."netbox_device_primary_ip"."slzb06_ip_primary" = {
        device_id = "\${netbox_device.slzb06.id}";
        ip_address_id = "\${netbox_ip_address.slzb06_ip1.id}";
    };

    # ser2net bridge that Home Assistant connects to for the Zigbee radio
    resource."netbox_service"."slzb06_ser2net" = {
        name = "ser2net (Zigbee)";
        device_id = "\${netbox_device.slzb06.id}";
        protocol = "tcp";
        ports = [6638];
    };
}
