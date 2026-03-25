{config, ... }:
{
    resource."netbox_device_type"."lenovo_m900" = {
        model = "Lenovo ThinkCentre M900 Tiny";
        manufacturer_id = "\${netbox_manufacturer.lenovo.id}";
        u_height = 1;
    };
}