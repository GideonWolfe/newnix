{config, ... }:
{
    resource."netbox_device"."mikrotik_rb5009" = {
        name = "MikroTik RB5009";
        device_type_id = "\${netbox_device_type.mikrotik_rb5009.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.router.id}";
        rack_id = "\${netbox_rack.home_network_rack.id}";
        rack_position = 4;
        rack_face = "front";
        status = "planned";
    };
}