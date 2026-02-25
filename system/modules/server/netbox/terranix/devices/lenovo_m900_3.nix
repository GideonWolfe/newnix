{config, ... }:
{
    # Define the device
    resource."netbox_device"."lenovo_m900_3" = {
        name = "Lenovo M900 Tiny #3";
        device_type_id = "\${netbox_device_type.lenovo_m900.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.compute.id}";
        rack_id = "\${netbox_rack.home_compute_rack.id}";
        rack_position = 7;
        rack_face = "front";
        status = "active";
        comments = "[Lenovo M900 Tiny Datasheet](https://psref.lenovo.com/syspool/Sys/PDF/ThinkCentre/ThinkCentre_M900_Tiny/ThinkCentre_M900_Tiny_Spec.PDF)";
    };

    # Define the device's power port
    resource."netbox_device_power_port"."lenovo_m900_3_power1" = {
        name = "DC Power";
        device_id = "\${netbox_device.lenovo_m900_3.id}";
        type = "dc-terminal";
        maximum_draw = 90;
        allocated_draw = 66;
    };

    resource."netbox_device_interface"."lenovo_m900_3_ether1" = {
        name = "ether1";
        device_id = "\${netbox_device.lenovo_m900_3.id}";
        type = "1000base-t";
    };

    # Assign an IP to this machine
    resource."netbox_ip_address"."lenovo_m900_3_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.proxmox.nodes.pve3.ip}/24";
        device_interface_id = "\${netbox_device_interface.lenovo_m900_3_ether1.id}";
        status = "active";
    };
    # Make it the primary address
    resource."netbox_device_primary_ip"."lenovo_m900_3_ip_primary" = {
        device_id = "\${netbox_device.lenovo_m900_3.id}";
        ip_address_id = "\${netbox_ip_address.lenovo_m900_3_ip1.id}";
    };

    # Define a cable connecting to the switch
    resource."netbox_cable"."lenovo_m900_3_ether1_cable" = {
        # Starting at the local device ethernet port
        a_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.lenovo_m900_3_ether1.id}";
        };
        # Ending at the switch's port 6
        b_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.mikrotik_css318_port6.id}";
        };
        status = "connected";
        label = "Lenovo M900 #3 Ethernet to Switch Port 6";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };
}