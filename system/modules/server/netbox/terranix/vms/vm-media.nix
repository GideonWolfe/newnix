{config, ... }:
{
    resource."netbox_virtual_machine"."vm-media" = {
        name = "media";
        cluster_id = "\${netbox_cluster.home.id}";
    };
    resource."netbox_virtual_disk"."vm-media-boot-disk" = {
        name = "media-vm-boot-disk";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        description = "Boot disk for media VM";
        size_mb = 30000;
    };
    resource."netbox_virtual_disk"."vm-media-data-disk" = {
        name = "media-vm-data-disk";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        description = "Data disk for media VM";
        size_mb = 23000;
    };

    # Define Virtual NIC for the VM
    resource."netbox_interface"."vm_media_ether0" = {
        name = "ens18";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
    };

    # Assign an IP to this VM
    resource."netbox_ip_address"."vm_media_ip1" = {
        ip_address = "${builtins.toString config.custom.world.hosts.proxmox.vms.media_vm.ip}/24";
        virtual_machine_interface_id = "\${netbox_interface.vm_media_ether0.id}";
        status = "active";
    };
    # Make it the primary address
    resource."netbox_primary_ip"."vm_media_ip_primary" = {
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        ip_address_id = "\${netbox_ip_address.vm_media_ip1.id}";
    };


    # This VM is reachable over SSH
    resource."netbox_service"."vm_media_ssh" = {
        name = "SSH";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [22];
    };
}