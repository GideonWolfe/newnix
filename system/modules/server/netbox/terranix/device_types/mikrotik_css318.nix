{config, ... }:
{
    resource."netbox_device_type"."mikrotik_css318" = {
        model = "MikroTik CSS318-16G-2S+in";
        manufacturer_id = "\${netbox_manufacturer.mikrotik.id}";
        u_height = 1;
    };
}