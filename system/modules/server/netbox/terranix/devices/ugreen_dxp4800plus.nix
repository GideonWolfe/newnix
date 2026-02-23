{config, ... }:
{
    # Define the device
    resource."netbox_device"."ugreen_dxp4800plus" = {
        name = "UGREEN DXP4800 Plus NAS";
        device_type_id = "\${netbox_device_type.ugreen_dxp4800plus.id}";
        site_id = "\${netbox_site.home.id}";
        role_id = "\${netbox_device_role.compute.id}";
        rack_id = "\${netbox_rack.home_compute_rack.id}";
        rack_position = 1;
        rack_face = "front";
        status = "active";
        comments = "[UGREEN DXP4800 Plus Datasheet](https://nas.ugreen.com/products/ugreen-nasync-dxp4800-4-bay-nas-136tb)";
    };

    # Define the device's power port
    resource."netbox_device_power_port"."ugreen_dxp4800plus_power1" = {
        name = "DC Power";
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
        type = "dc-terminal";
        maximum_draw = 90;
    };


    # Define HDD bays in the device
    resource."netbox_device_module_bay"."ugreen_dxp4800plus_module_bay1" = {
        name = "HDD Bay 1";
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
    };
    resource."netbox_device_module_bay"."ugreen_dxp4800plus_module_bay2" = {
        name = "HDD Bay 2";
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
    };
    resource."netbox_device_module_bay"."ugreen_dxp4800plus_module_bay3" = {
        name = "HDD Bay 3";
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
    };
    resource."netbox_device_module_bay"."ugreen_dxp4800plus_module_bay4" = {
        name = "HDD Bay 4";
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
    };

    # Define a module type for our HDDs
    resource."netbox_module_type"."ugreen_dxp4800plus_hdd" = {
        manufacturer_id = "\${netbox_manufacturer.western_digital.id}";
        model = "Western Digital Ultrastar DC HC570";
    };

    # Populate the bays with HDDs
    resource."netbox_module"."ugreen_dxp4800plus_hdd1" = {
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
        module_type_id = "\${netbox_module_type.ugreen_dxp4800plus_hdd.id}";
        module_bay_id = "\${netbox_device_module_bay.ugreen_dxp4800plus_module_bay1.id}";
        description = "22TB";
        status = "active";
    };
    resource."netbox_module"."ugreen_dxp4800plus_hdd2" = {
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
        module_type_id = "\${netbox_module_type.ugreen_dxp4800plus_hdd.id}";
        module_bay_id = "\${netbox_device_module_bay.ugreen_dxp4800plus_module_bay2.id}";
        description = "22TB";
        status = "active";
    };
    resource."netbox_module"."ugreen_dxp4800plus_hdd3" = {
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
        module_type_id = "\${netbox_module_type.ugreen_dxp4800plus_hdd.id}";
        module_bay_id = "\${netbox_device_module_bay.ugreen_dxp4800plus_module_bay3.id}";
        description = "22TB";
        status = "active";
    };
    resource."netbox_module"."ugreen_dxp4800plus_hdd4" = {
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
        module_type_id = "\${netbox_module_type.ugreen_dxp4800plus_hdd.id}";
        module_bay_id = "\${netbox_device_module_bay.ugreen_dxp4800plus_module_bay4.id}";
        description = "22TB";
        status = "active";
    };

    # Define devices network interfaces
    resource."netbox_device_interface"."ugreen_dxp4800plus_ether1" = {
        name = "ether1";
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
        type = "1000base-t";
    };
    resource."netbox_device_interface"."ugreen_dxp4800plus_ether2" = {
        name = "ether2";
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
        type = "2.5gbase-t";
    };

    # Assign an IP to this machine
    resource."netbox_ip_address"."ugreen_dxp4800plus_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.mnemosyne.ip}/24";
        device_interface_id = "\${netbox_device_interface.ugreen_dxp4800plus_ether2.id}";
        status = "active";
    };
    # Make it the primary address
    resource."netbox_device_primary_ip"."ugreen_dxp4800plus_ip_primary" = {
        device_id = "\${netbox_device.ugreen_dxp4800plus.id}";
        ip_address_id = "\${netbox_ip_address.ugreen_dxp4800plus_ip1.id}";
    };

    # Define a cable connecting to the switch
    resource."netbox_cable"."ugreen_dxp4800plus_ether2_cable" = {
        # Starting at the local device ethernet port
        a_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.ugreen_dxp4800plus_ether2.id}";
        };
        # Ending at the switch's port 8
        b_termination = {
            object_type = "dcim.interface";
            object_id = "\${netbox_device_interface.mikrotik_css318_port8.id}";
        };
        status = "connected";
        label = "UGREEN DXP4800 Plus Ethernet to Switch Port 8";
        type = "cat6a";
        length = 6;
        length_unit = "in";
    };
}