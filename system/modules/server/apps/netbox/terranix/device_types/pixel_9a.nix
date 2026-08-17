{config, ... }:
{
    resource."netbox_device_type"."pixel_9a" = {
        model = "Pixel 9a";
        manufacturer_id = "\${netbox_manufacturer.google.id}";
        u_height = 0;
    };
}
