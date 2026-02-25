{config, ... }:
{
    resource."netbox_device_type"."ugreen_dxp2800" = {
        model = "UGREEN NASync DXP2800";
        manufacturer_id = "\${netbox_manufacturer.ugreen.id}";
        u_height = 4;
    };
}