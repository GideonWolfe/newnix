{lib, config, ...}:
{
    sops = {
        # Tell SOPS to get secrets from the VM specific file in the same dir
        defaultSopsFile = lib.mkForce ./secrets_mikrotik.yaml;
        secrets = {
            "mikrotik/rb5009/username" = {};
            "mikrotik/rb5009/password" = {};
            "mikrotik/hapax2/username" = {};
            "mikrotik/hapax2/password" = {};
        };

        # Render the mikrotik-exporter config file at runtime with the real
        # credentials substituted in (kept out of the Nix store). JSON is
        # valid YAML, so we can build the structure with builtins.toJSON.
        templates."mikrotik-exporter-config.yaml".content = builtins.toJSON {
            devices = [
                {
                    name = "rb5009";
                    address = config.custom.world.hosts.router.ip;
                    user = config.sops.placeholder."mikrotik/rb5009/username";
                    password = config.sops.placeholder."mikrotik/rb5009/password";
                }
                {
                    name = "hapax2";
                    address = config.custom.world.hosts.access_point.ip;
                    user = config.sops.placeholder."mikrotik/hapax2/username";
                    password = config.sops.placeholder."mikrotik/hapax2/password";
                }
            ];
            features = {
                # bgp disabled: neither device runs BGP, so the exporter's
                # /routing/bgp queries return "no such command prefix".
                dhcp = true;
                dhcpl = true;
                routes = true;
                pools = true;
                optics = true;
                wlanif = true;
                wlansta = true;
            };
        };
    };
}
