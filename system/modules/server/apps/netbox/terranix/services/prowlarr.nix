{config, ... }:
{
    resource."netbox_service"."prowlarr" = {
        name = "Prowlarr";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.prowlarr.port];
    };
}
