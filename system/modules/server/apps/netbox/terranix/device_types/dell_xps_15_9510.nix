{config, ... }:
{
    resource."netbox_device_type"."dell_xps_15_9510" = {
        model = "Dell XPS 15 9510";
        manufacturer_id = "\${netbox_manufacturer.dell.id}";
        u_height = 0;
    };
}
