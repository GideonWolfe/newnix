{config, ... }:
{
    resource."netbox_service"."soulsync" = {
        name = "SoulSync";
        virtual_machine_id = "\${netbox_virtual_machine.vm-media.id}";
        protocol = "tcp";
        ports = [config.custom.world.services.soulsync-webui.port];
    };
}
