{config, ... }:
{
    resource."netbox_device_type"."mikrotik_rb5009" = {
        model = "MikroTik RB5009";
        manufacturer_id = "\${netbox_manufacturer.mikrotik.id}";
        u_height = 0.5;
    };
}