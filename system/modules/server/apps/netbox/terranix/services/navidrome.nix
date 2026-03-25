{config, ... }:
{
    resource."netbox_service"."navidrome" = {
        name = "Navidrome";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.navidrome.port];
    };
}
