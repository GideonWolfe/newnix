{
    services.prometheus.exporters.mikrotik = {
        enable = true;
        #port = 9189;
        openFirewall = true;
        configuration = {
            devices = [
                {
                    name = "rb5009";
                    address = "${config.custom.world.hosts.router.ip}";
                    user = config.sops.secrets."mikrotik/rb5009".username;
                    password = config.sops.secrets."mikrotik/rb5009".password;
                }
                {
                    name = "hapax2";
                    address = "${config.custom.world.hosts.access_point.ip}";
                    user = config.sops.secrets."mikrotik/hapax2".username;
                    password = config.sops.secrets."mikrotik/hapax2".password;
                }
            ]
            features = {
                bgp = true;
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