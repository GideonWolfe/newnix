{config, ... }:
{
    resource."netbox_service"."seerr" = {
        name = "Seerr";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.seerr.port];
    };
}
