{config, ... }:
{
    resource."netbox_device_type"."deskpi_patch_panel_1u" = {
        model = "Deskpi Patch Panel 1U";
        manufacturer_id = "\${netbox_manufacturer.deskpi.id}";
        u_height = 1;
    };
}