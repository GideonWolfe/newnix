{config, ... }:
{
    # Define the device
    resource."netbox_device"."deskpi_patch_panel_1u" = {
        name = "DeskPi Patch Panel 1U";
        device_type_id = "\${netbox_device_type.deskpi_patch_panel_1u.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.patch_panel.id}";
        rack_id = "\${netbox_rack.home_network_rack.id}";
        rack_position = 4;
        rack_face = "rear";
        status = "active";
        comments = "[Product Page](https://deskpi.com/products/deskpi-rackmate-12-port-cat6-keystone-patch-panel-10inch-1u-network-patch-panel-with-cable-management)";
    };


    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether1_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 1";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether1_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 1";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether1_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether2_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 2";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether2_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 2";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether2_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether3_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 3";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether3_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 3";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether3_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether4_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 4";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether4_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 4";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether4_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether5_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 5";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether5_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 5";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether5_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether6_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 6";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether6_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 6";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether6_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether7_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 7";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether7_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 7";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether7_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether8_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 8";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether8_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 8";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether8_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether9_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 9";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether9_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 9";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether9_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether10_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 10";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether10_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 10";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether10_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether11_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 11";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether11_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 11";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether11_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_1u_ether12_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "rear port 12";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_1u_ether12_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_1u.id}";
        name = "front port 12";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether12_rear.id}";
        rear_port_position = 1;
    };


    # Cables going from the rear ports of the 1u patch panel to the rear ports of the 0.5u patch panel
    resource."netbox_cable"."patch_panel_1u_ether1_rear_to_patch_panel_halfu_ether12_rear" = {
        # Starting at the rear patch panel rear port
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether1_rear.id}";
        };
        # Ending at the rear patch panel rear port
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether12_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 1 Rear to Patch Panel HalfU Port 12 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_1u_ether2_rear_to_patch_panel_halfu_ether11_rear" = {
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether2_rear.id}";
        };
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether11_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 2 Rear to Patch Panel HalfU Port 11 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_1u_ether3_rear_to_patch_panel_halfu_ether10_rear" = {
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether3_rear.id}";
        };
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether10_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 3 Rear to Patch Panel HalfU Port 10 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_1u_ether4_rear_to_patch_panel_halfu_ether9_rear" = {
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether4_rear.id}";
        };
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether9_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 4 Rear to Patch Panel HalfU Port 9 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_1u_ether5_rear_to_patch_panel_halfu_ether8_rear" = {
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether5_rear.id}";
        };
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether8_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 5 Rear to Patch Panel HalfU Port 8 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_1u_ether6_rear_to_patch_panel_halfu_ether7_rear" = {
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether6_rear.id}";
        };
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether7_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 6 Rear to Patch Panel HalfU Port 7 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_1u_ether7_rear_to_patch_panel_halfu_ether6_rear" = {
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether7_rear.id}";
        };
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether6_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 7 Rear to Patch Panel HalfU Port 6 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_1u_ether8_rear_to_patch_panel_halfu_ether5_rear" = {
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether8_rear.id}";
        };
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether5_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 8 Rear to Patch Panel HalfU Port 5 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_1u_ether9_rear_to_patch_panel_halfu_ether4_rear" = {
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether9_rear.id}";
        };
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether4_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 9 Rear to Patch Panel HalfU Port 4 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_1u_ether10_rear_to_patch_panel_halfu_ether3_rear" = {
        a_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_1u_ether10_rear.id}";
        };
        b_termination = {
            object_type = "dcim.rearport";
            object_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether3_rear.id}";
        };
        status = "connected";
        label = "Patch Panel 1U Port 10 Rear to Patch Panel HalfU Port 3 Rear";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

}