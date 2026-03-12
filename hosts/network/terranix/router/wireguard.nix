{config, ... }:
{
  resource."routeros_interface_wireguard"."wg0" = {
    name = "wg0";
    listen_port = "${builtins.toString config.custom.world.hosts.router.wireguard.port}";
    provider = "routeros.router";
    private_key = "\${var.router_wireguard_private_key}";
  };

  resource."routeros_ip_address"."wg0" = {
    address = "${config.custom.world.hosts.router.wireguard.ip}/24";
    interface = "\${routeros_interface_wireguard.wg0.name}";
    provider = "routeros.router";
  };

  resource."routeros_interface_wireguard_peer"."poseidon" = {
    interface = "\${routeros_interface_wireguard.wg0.name}";
    public_key = config.custom.world.hosts.poseidon.wireguard.public_key;
    allowed_address = config.custom.world.hosts.poseidon.wireguard.ip;
    provider = "routeros.router";
  };
}