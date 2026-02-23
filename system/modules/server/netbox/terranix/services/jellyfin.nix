{config, ... }:
{
    resource."netbox_service"."jellyfin" = {
        name = "Jellyfin";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.jellyfin.port];
    };
}