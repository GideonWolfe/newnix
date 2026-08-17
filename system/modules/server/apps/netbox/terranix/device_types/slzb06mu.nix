{config, ... }:
{
    resource."netbox_device_type"."slzb06mu" = {
        model = "SLZB-06MU";
        manufacturer_id = "\${netbox_manufacturer.smlight.id}";
        u_height = 0;
    };
}
