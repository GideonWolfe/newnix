{ config, lib, pkgs, inputs, ... }:
{
    # Open firewall for WireGuard
    networking.firewall.allowedUDPPorts = [
      config.custom.world.hosts.router.wireguard.port
    ];

    # Configure WireGuard interface
    networking.wireguard.interfaces.wg0 = {
      ips = [ "${config.custom.world.hosts.${config.networking.hostName}.wireguard.ip}/24" ];

      # Always generate private key automatically
      generatePrivateKeyFile = true;
      privateKeyFile = "/root/wireguard/${config.networking.hostName}-wg0-private.key";

      # Server peer configuration
      peers = [{
        # Server public key from world config
        publicKey = config.custom.world.hosts.router.wireguard.public_key;

        allowedIPs = [
          # Route LAN traffic through the VPN
          config.custom.world.hosts.router.subnet
          # Route VPN subnet traffic through the VPN
          config.custom.world.hosts.router.wireguard.subnet
        ];

        # Server endpoint constructed from IP and port
        endpoint = "24.168.123.112:${toString config.custom.world.hosts.router.wireguard.port}";

        # Keep NAT tables alive
        persistentKeepalive = 25;
      }];
    };
}