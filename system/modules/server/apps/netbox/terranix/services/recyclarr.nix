{config, ... }:
{
    resource."netbox_service"."recyclarr" = {
        name = "Recyclarr";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.recyclarr.port];
    };
}
