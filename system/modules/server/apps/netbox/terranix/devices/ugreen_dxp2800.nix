{config, ... }:
{
    # Define the device
    resource."netbox_device"."ugreen_dxp2800" = {
        name = "UGREEN DXP2800 NAS";
        device_type_id = "\${netbox_device_type.ugreen_dxp2800.id}";
        site_id = "\${netbox_site.offsite.id}";
        role_id = "\${netbox_device_role.compute.id}";
        rack_id = "\${netbox_rack.offsite_compute_rack.id}";
        rack_position = 1;
        rack_face = "front";
        status = "active";
        comments = "[UGREEN DXP2800 Datasheet](https://nas.ugreen.com/products/ugreen-nasync-dxp2800-nas-storage)";
    };

    # Define the device's power port
    resource."netbox_device_power_port"."ugreen_dxp2800_power1" = {
        name = "DC Power";
        device_id = "\${netbox_device.ugreen_dxp2800.id}";
        type = "dc-terminal";
        maximum_draw = 65;
    };


    # Define HDD bays in the device
    resource."netbox_device_module_bay"."ugreen_dxp2800_module_bay1" = {
        name = "HDD Bay 1";
        device_id = "\${netbox_device.ugreen_dxp2800.id}";
    };
    resource."netbox_device_module_bay"."ugreen_dxp2800_module_bay2" = {
        name = "HDD Bay 2";
        device_id = "\${netbox_device.ugreen_dxp2800.id}";
    };

    # Define a module type for our HDDs
    resource."netbox_module_type"."ugreen_dxp2800_hdd" = {
        manufacturer_id = "\${netbox_manufacturer.western_digital.id}";
        model = "Western Digital Ultrastar DC HC330";
    };

    # Populate the bays with HDDs
    resource."netbox_module"."ugreen_dxp2800_hdd1" = {
        device_id = "\${netbox_device.ugreen_dxp2800.id}";
        module_type_id = "\${netbox_module_type.ugreen_dxp2800_hdd.id}";
        module_bay_id = "\${netbox_device_module_bay.ugreen_dxp2800_module_bay1.id}";
        description = "10TB";
        status = "active";
    };
    resource."netbox_module"."ugreen_dxp2800_hdd2" = {
        device_id = "\${netbox_device.ugreen_dxp2800.id}";
        module_type_id = "\${netbox_module_type.ugreen_dxp2800_hdd.id}";
        module_bay_id = "\${netbox_device_module_bay.ugreen_dxp2800_module_bay2.id}";
        description = "10TB";
        status = "active";
    };

    # Define devices network interfaces
    resource."netbox_device_interface"."ugreen_dxp2800_ether1" = {
        name = "ether1";
        device_id = "\${netbox_device.ugreen_dxp2800.id}";
        type = "2.5gbase-t";
    };

    # Assign an IP to this machine
    resource."netbox_ip_address"."ugreen_dxp2800_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.soteria.ip}/24";
        device_interface_id = "\${netbox_device_interface.ugreen_dxp2800_ether1.id}";
        status = "active";
    };
    # Make it the primary address
    resource."netbox_device_primary_ip"."ugreen_dxp2800_ip_primary" = {
        device_id = "\${netbox_device.ugreen_dxp2800.id}";
        ip_address_id = "\${netbox_ip_address.ugreen_dxp2800_ip1.id}";
    };
}