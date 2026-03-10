{config, ... }:
{
    # Define the device
    resource."netbox_device"."beelink_u59" = {
        name = "Beelink U59";
        device_type_id = "\${netbox_device_type.beelink_u59.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.compute.id}";
        rack_id = "\${netbox_rack.home_network_rack.id}";
        rack_position = 1;
        rack_face = "front";
        status = "active";
        comments = "[Beelink U59 (Amazon listing)](https://www.amazon.com/Beelink-Computers-Generation-Quad-Core-Billboard/dp/B09GFTJHX7)";
    };

    # Define the device's power port
    resource."netbox_device_power_port"."beelink_u59_power1" = {
        name = "DC Power";
        device_id = "\${netbox_device.beelink_u59.id}";
        type = "dc-terminal";
        maximum_draw = 36;
        allocated_draw = 30;
    };

    resource."netbox_device_interface"."beelink_u59_ether1" = {
        name = "ether1";
        device_id = "\${netbox_device.beelink_u59.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."beelink_u59_ether2" = {
        name = "ether2";
        device_id = "\${netbox_device.beelink_u59.id}";
        type = "1000base-t";
    };

    # Assign an IP to this machine
    resource."netbox_ip_address"."beelink_u59_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.proxmox.nodes.pvenet.ip}/24";
        device_interface_id = "\${netbox_device_interface.beelink_u59_ether1.id}";
        status = "active";
    };
    # Make it the primary address
    resource."netbox_device_primary_ip"."beelink_u59_ip_primary" = {
        device_id = "\${netbox_device.beelink_u59.id}";
        ip_address_id = "\${netbox_ip_address.beelink_u59_ip1.id}";
    };

    # Define a cable connecting the miniPC to the patch panel
    resource."netbox_cable"."beelink_u59_ether1_to_patch_panel_1u_ether2_rear" = {
        # Starting at the local device ethernet port
        a_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.beelink_u59_ether1.id}";
        };
        # Ending at the rear of the patch panel
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether2_rear.id}";
        };
        status = "connected";
        label = "Beelink U59 Ethernet to Front Patch Panel Rear Port 2";
        type = "cat6a";
        length = 12;
        length_unit = "in";
    };
    # Complete the run going from the front of the patch panel to the router
    resource."netbox_cable"."patch_panel_halfu_ether2_front_to_router_ether3" = {
        # Starting at the patch panel front port
        a_termination = {
            object_type = "dcim.frontport";
            object_id = "\${netbox_device_front_port.deskpi_patch_panel_halfu_ether2_front.id}";
        };
        # Ending at the front of the router
        b_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.mikrotik_rb5009_ether3.id}";
        };
        status = "connected";
        label = "Beelink U59 Ethernet to Patch Panel Port 2 (router ether3)";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };
}