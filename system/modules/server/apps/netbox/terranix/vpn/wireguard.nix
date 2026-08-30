{ config, ... }:
# The "wg-home" WireGuard mesh, modeled with NetBox's native VPN tunnel objects.
#
# Topology: hub-and-spoke. The MikroTik router is the HUB; every remote NixOS
# host / mobile device is a SPOKE that dials in. Overlay subnet 10.0.0.0/24
# (defined in lib/world/hosts.nix as router.wireguard.subnet).
#
# NOTE on encapsulation: the e-breuninger/netbox provider (v5.x) hardcodes the
# allowed encapsulation values to ipsec-transport/ipsec-tunnel/ip-ip/gre and does
# NOT yet accept "wireguard" (which NetBox itself supports). We use "ip-ip" as a
# structural stand-in and make the real protocol explicit in the name/description.
# Switch to "wireguard" once the provider exposes it.
let
  h = config.custom.world.hosts;
in
{
    # Group that contains the tunnel(s).
    resource."netbox_vpn_tunnel_group"."wg_home" = {
        name = "wg-home";
        description = "Home WireGuard hub-and-spoke mesh (overlay ${h.router.wireguard.subnet})";
    };

    # The tunnel itself. Multiple terminations (one hub + N spokes) hang off it.
    resource."netbox_vpn_tunnel"."wg_home" = {
        name = "wg-home";
        encapsulation = "ip-ip"; # stand-in for WireGuard (see note above)
        status = "active";
        tunnel_group_id = "\${netbox_vpn_tunnel_group.wg_home.id}";
        description = "WireGuard tunnel. Hub: router ${h.router.wireguard.ip}. Overlay ${h.router.wireguard.subnet}.";
    };

    # --- Hub termination (the router) ---
    resource."netbox_vpn_tunnel_termination"."wg_home_hub" = {
        tunnel_id = "\${netbox_vpn_tunnel.wg_home.id}";
        role = "hub";
        device_interface_id = "\${netbox_device_interface.mikrotik_rb5009_wg0.id}";
    };

    # --- Spoke terminations (each remote peer's wg0 interface) ---
    resource."netbox_vpn_tunnel_termination"."wg_home_soteria" = {
        tunnel_id = "\${netbox_vpn_tunnel.wg_home.id}";
        role = "spoke";
        device_interface_id = "\${netbox_device_interface.ugreen_dxp2800_wg0.id}";
    };
    resource."netbox_vpn_tunnel_termination"."wg_home_poseidon" = {
        tunnel_id = "\${netbox_vpn_tunnel.wg_home.id}";
        role = "spoke";
        device_interface_id = "\${netbox_device_interface.poseidon_wg0.id}";
    };
    resource."netbox_vpn_tunnel_termination"."wg_home_ares" = {
        tunnel_id = "\${netbox_vpn_tunnel.wg_home.id}";
        role = "spoke";
        device_interface_id = "\${netbox_device_interface.ares_wg0.id}";
    };
    resource."netbox_vpn_tunnel_termination"."wg_home_pixel9a" = {
        tunnel_id = "\${netbox_vpn_tunnel.wg_home.id}";
        role = "spoke";
        device_interface_id = "\${netbox_device_interface.pixel9a_wg0.id}";
    };
    resource."netbox_vpn_tunnel_termination"."wg_home_retroidpocket6" = {
        tunnel_id = "\${netbox_vpn_tunnel.wg_home.id}";
        role = "spoke";
        device_interface_id = "\${netbox_device_interface.retroidpocket6_wg0.id}";
    };
}
