{config, ... }:
{
    resource."netbox_device_type"."lenovo_thinkpad_t490" = {
        model = "Lenovo ThinkPad T490";
        manufacturer_id = "\${netbox_manufacturer.lenovo.id}";
        u_height = 0; # laptop, not rack-mounted
    };
}
