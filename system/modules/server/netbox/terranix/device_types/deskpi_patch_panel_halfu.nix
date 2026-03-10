{config, ... }:
{
    resource."netbox_device_type"."deskpi_patch_panel_halfu" = {
        model = "Deskpi Patch Panel 0.5U";
        manufacturer_id = "\${netbox_manufacturer.deskpi.id}";
        u_height = 0.5;
    };
}