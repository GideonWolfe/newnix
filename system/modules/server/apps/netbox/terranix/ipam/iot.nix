{ config, ... }:
let
  iot = config.custom.world.networks.iot;
in
{
    # Functional role shared by the IoT VLAN and its prefix. In NetBox a prefix
    # is conventionally assigned the same role as the VLAN it belongs to.
    resource."netbox_ipam_role"."iot" = {
        name = "IoT";
        slug = "iot";
        description = "Untrusted smart-home devices, firewalled off the main LAN";
    };

    # The IoT VLAN itself (802.1Q), scoped to the Home site's VLAN group.
    resource."netbox_vlan"."iot" = {
        name = "IoT";
        vid = iot.vlan_id;
        status = "active";
        site_id = "\${netbox_site.home.id}";
        group_id = "\${netbox_vlan_group.home.id}";
        role_id = "\${netbox_ipam_role.iot.id}";
        description = "Isolated VLAN for untrusted WiFi smart-home devices";
    };

    # Layer-3 subnet bound to the IoT VLAN.
    resource."netbox_prefix"."iot" = {
        prefix = iot.subnet;
        status = "active";
        site_id = "\${netbox_site.home.id}";
        vlan_id = "\${netbox_vlan.iot.id}";
        role_id = "\${netbox_ipam_role.iot.id}";
        description = "IoT VLAN subnet (gateway ${iot.gateway}, DNS ${iot.dns})";
    };

    # DHCP pool handed out to IoT devices by the router.
    resource."netbox_ip_range"."iot_dhcp" = {
        start_address = "${iot.dhcp.start}/24";
        end_address = "${iot.dhcp.end}/24";
        status = "active";
        role_id = "\${netbox_ipam_role.iot.id}";
        description = "IoT DHCP pool";
    };
}
