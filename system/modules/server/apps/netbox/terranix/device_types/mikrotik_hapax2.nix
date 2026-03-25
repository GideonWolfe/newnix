{config, ... }:
{
    resource."netbox_device_type"."mikrotik_hapax2" = {
        model = "MikroTik hAP ax2";
        manufacturer_id = "\${netbox_manufacturer.mikrotik.id}";
        u_height = 1;
    };
}