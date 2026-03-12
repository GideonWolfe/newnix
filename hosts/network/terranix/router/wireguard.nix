{config, ... }:
{
  resource."routeros_interface_wireguard"."wg0" = {
    name = "wg0";
    listen_port = "${builtins.toString config.custom.world.hosts.router.wireguard.port}";
    provider = "routeros.router";
    private_key = "\${var.router_wireguard_private_key}";
  };

  resource."routeros_ip_address"."wg0" = {
    address = "${config.custom.world.hosts.router.wg_ip}/24";
    interface = "\${routeros_interface_wireguard.wg0.name}";
    provider = "routeros.router";
  };
}