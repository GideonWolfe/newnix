{config, ... }:
{
    # Define the device
    resource."netbox_device"."mikrotik_css318" = {
        name = "MikroTik CSS318-16G-2S+in";
        device_type_id = "\${netbox_device_type.mikrotik_css318.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.switch.id}";
        rack_id = "\${netbox_rack.home_compute_rack.id}";
        rack_position = 6;
        rack_face = "front";
        status = "active";
        comments = "[Product Page](https://mikrotik.com/product/css318_16g_2s_in)";
    };

    # Define the device's power port
    resource."netbox_device_power_port"."mikrotik_css318_power1" = {
        name = "PSU 0";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "iec-60320-c6";
        maximum_draw = 13;
    };


    # Regular 1G ethernet ports
    resource."netbox_device_interface"."mikrotik_css318_port1" = {
        name = "port1";
        label = "1";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port2" = {
        name = "port2";
        label = "2";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port3" = {
        name = "port3";
        label = "3";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port4" = {
        name = "port4";
        label = "4";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port5" = {
        name = "port5";
        label = "5";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port6" = {
        name = "port6";
        label = "6";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port7" = {
        name = "port7";
        label = "7";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port8" = {
        name = "port8";
        label = "8";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port9" = {
        name = "port9";
        label = "9";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port10" = {
        name = "port10";
        label = "10";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port11" = {
        name = "port11";
        label = "11";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port12" = {
        name = "port12";
        label = "12";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port13" = {
        name = "port13";
        label = "13";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port14" = {
        name = "port14";
        label = "14";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port15" = {
        name = "port15";
        label = "15";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."mikrotik_css318_port16" = {
        name = "port16";
        label = "16";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "1000base-t";
    };


    # SFP+ Cages
    resource."netbox_device_interface"."mikrotik_css318_sfp1" = {
        name = "sfp1";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "10gbase-x-sfpp";
    };
    resource."netbox_device_interface"."mikrotik_css318_sfp2" = {
        name = "sfp2";
        device_id = "\${netbox_device.mikrotik_css318.id}";
        type = "10gbase-x-sfpp";
    };


}