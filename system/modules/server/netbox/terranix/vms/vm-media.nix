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
}