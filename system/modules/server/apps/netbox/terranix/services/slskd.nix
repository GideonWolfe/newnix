{config, ... }:
{
    resource."netbox_service"."slskd" = {
        name = "slskd";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.slskd.port];
    };
}
