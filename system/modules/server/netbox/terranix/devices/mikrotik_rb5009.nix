{config, ... }:
{
    # Define the device
    resource."netbox_device"."mikrotik_rb5009" = {
        name = "MikroTik RB5009";
        device_type_id = "\${netbox_device_type.mikrotik_rb5009.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.router.id}";
        rack_id = "\${netbox_rack.home_network_rack.id}";
        rack_position = 4;
        rack_face = "front";
        status = "planned";
        comments = "[MikroTik RB5009UG+S+IN Datasheet](https://mikrotik.com/product/rb5009ug_s_in)";
    };

    # Define the device's power port
    resource."netbox_device_power_port"."mikrotik_rb5009_power1" = {
        name = "DC Power";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "dc-terminal";
        maximum_draw = 20;
        allocated_draw = 14;
    };
    resource."netbox_device_power_port"."mikrotik_rb5009_power2" = {
        name = "Hardwired Power";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "hardwired";
        maximum_draw = 20;
        allocated_draw = 14;
    };

    # Single 2.5G ethernet port
    resource."netbox_device_interface"."mikrotik_rb5009_ether1" = {
        name = "ether1";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "2.5gbase-t";
    };

    # 7 regular 1G ethernet ports
    resource."netbox_device_interface"."mikrotik_rb5009_ether2" = {
        name = "ether2";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_rb5009_ether3" = {
        name = "ether3";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_rb5009_ether4" = {
        name = "ether4";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_rb5009_ether5" = {
        name = "ether5";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_rb5009_ether6" = {
        name = "ether6";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_rb5009_ether7" = {
        name = "ether7";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_rb5009_ether8" = {
        name = "ether8";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "1000base-t";
    };


    # SFP+ Cage
    resource."netbox_device_interface"."mikrotik_rb5009_sfp" = {
        name = "sfp";
        device_id = "\${netbox_device.mikrotik_rb5009.id}";
        type = "10gbase-x-sfpp";
    };


}