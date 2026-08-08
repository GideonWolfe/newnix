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

      # We add the routes ourselves (see postSetup) so the LAN route can be
      # given a high metric. If the module added them automatically they'd land
      # at metric 0 and hijack local traffic whenever the host is physically on
      # the LAN.
      allowedIPsAsRoutes = false;

      # Server peer configuration
      peers = [{
        # Server public key from world config
        publicKey = config.custom.world.hosts.router.wireguard.public_key;

        # Cryptokey routing: permit both the VPN subnet and the home LAN to be
        # carried over the tunnel (required so a remote host can reach the LAN).
        # Whether the LAN is actually *reached* via the tunnel is decided by
        # route metrics in postSetup, not here.
        allowedIPs = [
          config.custom.world.hosts.router.wireguard.subnet
          config.custom.world.hosts.router.subnet
        ];

        # Server endpoint constructed from IP and port
        endpoint = "70.19.44.46:${toString config.custom.world.hosts.router.wireguard.port}";

        # Keep NAT tables alive
        persistentKeepalive = 25;
      }];

      # Install routes manually so a roaming host prefers the direct LAN path
      # when physically at home, and falls back to the tunnel when remote:
      #   * VPN subnet -> always via wg0
      #   * home LAN   -> via wg0 at a high metric, so the kernel's directly
      #     connected LAN route (low metric) wins when present; the tunnel route
      #     is only used when no direct route exists (i.e. the host is remote).
      postSetup = ''
        ${pkgs.iproute2}/bin/ip route replace ${config.custom.world.hosts.router.wireguard.subnet} dev wg0
        ${pkgs.iproute2}/bin/ip route replace ${config.custom.world.hosts.router.subnet} dev wg0 metric 1000
      '';
    };
}
