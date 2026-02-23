{config, ... }:
{
    resource."netbox_device_type"."ugreen_dxp4800plus" = {
        model = "UGREEN NASync DXP4800 Plus";
        manufacturer_id = "\${netbox_manufacturer.ugreen.id}";
        u_height = 5;
    };
}