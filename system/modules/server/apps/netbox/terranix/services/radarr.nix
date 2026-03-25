{config, ... }:
{
    resource."netbox_service"."radarr" = {
        name = "Radarr";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.radarr.port];
    };
}
