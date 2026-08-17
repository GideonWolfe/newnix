{config, ... }:
{
    resource."netbox_device_type"."retroid_pocket6" = {
        model = "Retroid Pocket 6";
        manufacturer_id = "\${netbox_manufacturer.retroid.id}";
        u_height = 0;
    };
}
