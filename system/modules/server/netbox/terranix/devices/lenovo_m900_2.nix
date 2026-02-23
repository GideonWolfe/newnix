{config, ... }:
{
    # Define the device
    resource."netbox_device"."lenovo_m900_2" = {
        name = "Lenovo M900 Tiny #2";
        device_type_id = "\${netbox_device_type.lenovo_m900.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.compute.id}";
        rack_id = "\${netbox_rack.home_compute_rack.id}";
        rack_position = 8;
        rack_face = "front";
        status = "active";
        comments = "[Lenovo M900 Tiny Datasheet](https://psref.lenovo.com/syspool/Sys/PDF/ThinkCentre/ThinkCentre_M900_Tiny/ThinkCentre_M900_Tiny_Spec.PDF)";
    };

    # Define the device's power port
    resource."netbox_device_power_port"."lenovo_m900_2_power1" = {
        name = "DC Power";
        device_id = "\${netbox_device.lenovo_m900_2.id}";
        type = "dc-terminal";
        maximum_draw = 90;
        allocated_draw = 66;
    };

    resource."netbox_device_interface"."lenovo_m900_2_ether1" = {
        name = "ether1";
        device_id = "\${netbox_device.lenovo_m900_2.id}";
        type = "1000base-t";
    };
}