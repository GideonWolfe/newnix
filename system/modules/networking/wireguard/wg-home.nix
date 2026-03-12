{ config, lib, pkgs, inputs, ... }:
{
    # Open firewall for WireGuard
    networking.firewall.allowedUDPPorts = [
      config.custom.world.hosts.wireguard.port
    ];

    # Configure WireGuard interface
    networking.wireguard.interfaces.wg0 = {
      # Client IP and subnet (auto-derived from world config)
      ips = [ "${config.custom.world.hosts.wireguard.clients.${config.networking.hostName}.vpnIp}/24" ];
      
      # Listen on the same port as configured in world
      listenPort = config.custom.world.hosts.router.wireguard.port;

      # Always generate private key automatically
      generatePrivateKeyFile = true;
      privateKeyFile = "/root/wireguard/${config.networking.hostName}-wg0-private.key";

      # Server peer configuration
      peers = [{
        # Server public key from world config
        publicKey = config.custom.world.hosts.router.wireguard.public_key;

        # Route only server traffic through VPN
        allowedIPs = [ config.custom.world.hosts.wireguard.vpnServerIp ];

        # TODO change port
        # Server endpoint constructed from IP and port
        endpoint = "${config.custom.world.hosts.router.ip}:${toString config.custom.world.hosts.wireguard.port}";

        # Keep NAT tables alive
        persistentKeepalive = 25;
      }];
    };
}