{config, ... }:
{
    resource."netbox_service"."nzbget" = {
        name = "NZBGet";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.nzbget.port];
    };
}
