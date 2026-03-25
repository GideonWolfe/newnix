{config, ... }:
{
    resource."netbox_device_type"."beelink_u59" = {
        model = "Beelink U59";
        manufacturer_id = "\${netbox_manufacturer.beelink.id}";
        u_height = 1;
    };
}