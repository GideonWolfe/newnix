{config, ... }:
{
    # Define the device
    resource."netbox_device"."deskpi_patch_panel_halfu" = {
        name = "DeskPi Patch Panel HalfU";
        device_type_id = "\${netbox_device_type.deskpi_patch_panel_halfu.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.patch_panel.id}";
        rack_id = "\${netbox_rack.home_network_rack.id}";
        rack_position = 3;
        rack_face = "front";
        status = "active";
        comments = "[Product Page](https://deskpi.com/products/deskpi-rackmate-accessory-10-inch-network-switch)";
    };


    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether1_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 1";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether1_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 1";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether1_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether2_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 2";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether2_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 2";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether2_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether3_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 3";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether3_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 3";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether3_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether4_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 4";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether4_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 4";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether4_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether5_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 5";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether5_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 5";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether5_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether6_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 6";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether6_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 6";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether6_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether7_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 7";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether7_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 7";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether7_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether8_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 8";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether8_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 8";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether8_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether9_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 9";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether9_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 9";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether9_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether10_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 10";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether10_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 10";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether10_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether11_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 11";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether11_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 11";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether11_rear.id}";
        rear_port_position = 1;
    };

    resource."netbox_device_rear_port"."deskpi_patch_panel_halfu_ether12_rear" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "rear port 12";
        type = "8p8c";
        positions = 1;
        mark_connected = false;
    };
    resource."netbox_device_front_port"."deskpi_patch_panel_halfu_ether12_front" = {
        device_id = "\${netbox_device.deskpi_patch_panel_halfu.id}";
        name = "front port 12";
        type = "8p8c";
        rear_port_id = "\${netbox_device_rear_port.deskpi_patch_panel_halfu_ether12_rear.id}";
        rear_port_position = 1;
    };


    # All the patch cables going from front ports into the router
    resource."netbox_cable"."patch_panel_halfu_ether12_front_to_router_ether8" = {
        # Starting at the patch panel front port
        a_termination = {
            object_type = "dcim.frontport";
            object_id = "\${netbox_device_front_port.deskpi_patch_panel_halfu_ether12_front.id}";
        };
        # Ending at the front of the router
        b_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.mikrotik_rb5009_ether8.id}";
        };
        status = "connected";
        label = "Patch Panel HalfU Port 12 Front to Router Ethernet 8";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };
    resource."netbox_cable"."patch_panel_halfu_ether11_front_to_router_ether7" = {
        # Starting at the patch panel front port
        a_termination = {
            object_type = "dcim.frontport";
            object_id = "\${netbox_device_front_port.deskpi_patch_panel_halfu_ether11_front.id}";
        };
        # Ending at the front of the router
        b_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.mikrotik_rb5009_ether7.id}";
        };
        status = "connected";
        label = "Patch Panel HalfU Port 11 Front to Router Ethernet 7";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_halfu_ether10_front_to_router_ether6" = {
        a_termination = {
            object_type = "dcim.frontport";
            object_id = "\${netbox_device_front_port.deskpi_patch_panel_halfu_ether10_front.id}";
        };
        b_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.mikrotik_rb5009_ether6.id}";
        };
        status = "connected";
        label = "Patch Panel HalfU Port 10 Front to Router Ethernet 6";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_halfu_ether9_front_to_router_ether5" = {
        a_termination = {
            object_type = "dcim.frontport";
            object_id = "\${netbox_device_front_port.deskpi_patch_panel_halfu_ether9_front.id}";
        };
        b_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.mikrotik_rb5009_ether5.id}";
        };
        status = "connected";
        label = "Patch Panel HalfU Port 9 Front to Router Ethernet 5";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    resource."netbox_cable"."patch_panel_halfu_ether8_front_to_router_ether4" = {
        a_termination = {
            object_type = "dcim.frontport";
            object_id = "\${netbox_device_front_port.deskpi_patch_panel_halfu_ether8_front.id}";
        };
        b_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.mikrotik_rb5009_ether4.id}";
        };
        status = "connected";
        label = "Patch Panel HalfU Port 8 Front to Router Ethernet 4";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };

    # mini pc should plug into ether3
    # resource."netbox_cable"."patch_panel_halfu_ether7_front_to_router_ether3" = {
    #     a_termination = {
    #         object_type = "dcim.frontport";
    #         object_id = "\${netbox_device_front_port.deskpi_patch_panel_halfu_ether7_front.id}";
    #     };
    #     b_termination = {
    #         object_type = "dcim.interface";
    #         object_id = "\${netbox_device_interface.mikrotik_rb5009_ether3.id}";
    #     };
    #     status = "connected";
    #     label = "Patch Panel HalfU Port 7 Front to Router Ethernet 3";
    #     type = "cat6a";
    #     length = 6;
    #     length_unit = "in";
    # };
}