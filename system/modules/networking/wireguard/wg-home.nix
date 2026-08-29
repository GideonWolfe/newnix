{ config, lib, pkgs, inputs, ... }:
let
  wg = config.custom.world.hosts.router.wireguard;
  # The hub's endpoint as a "host:port" string. `host` may be a DNS name so a
  # home WAN-IP change only needs a DNS-record update, not a redeploy.
  endpoint = "${wg.endpoint}:${toString wg.port}";
in
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

        # Server endpoint. Host may be a DNS name (see router.wireguard.endpoint)
        # so a home WAN-IP change only requires a DNS update. Note: the kernel
        # resolves this ONCE at interface setup, so remote hosts also run the
        # reresolve-dns timer below to pick up a changed IP without a reboot.
        endpoint = endpoint;

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

    # Periodically re-resolve the hub's endpoint hostname and update the peer if
    # its IP changed. The WireGuard kernel module only resolves `endpoint` once
    # at setup, so without this a home WAN-IP change would silently strand any
    # remote spoke on the stale IP (and the tunnel is the only way back in to
    # fix it). Harmless on LAN hosts. No-op unless the resolved IP actually
    # differs, so it won't churn the handshake.
    systemd.services.wg-reresolve-dns = {
      description = "Re-resolve WireGuard hub endpoint and update peer";
      after = [ "network-online.target" "wireguard-wg0.service" ];
      wants = [ "network-online.target" ];
      serviceConfig.Type = "oneshot";
      path = [ pkgs.wireguard-tools ];
      script = ''
        # `wg set ... endpoint <host:port>` re-resolves the hostname each run.
        # If the resolved IP is unchanged this is a no-op that does NOT reset
        # the handshake, so running it on a short timer is safe.
        wg set wg0 peer "${config.custom.world.hosts.router.wireguard.public_key}" \
          endpoint "${endpoint}"
      '';
    };
    systemd.timers.wg-reresolve-dns = {
      description = "Periodically re-resolve WireGuard hub endpoint";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "2min";
        OnUnitActiveSec = "2min";
      };
    };
}
