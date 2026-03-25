{config, ... }:
{
    resource."netbox_service"."sonarr" = {
        name = "Sonarr";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.sonarr.port];
    };
}
