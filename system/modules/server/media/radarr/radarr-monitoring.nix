# This module sets up the monitoring exporters for radarr
# It assumes this server/VM is already running prometheus and 
# is pushing metrics to the main monitoring server
{ lib, config, ... }:

{
    # https://github.com/onedr0p/exportarr
    services.prometheus.exporters.exportarr-radarr = {
        enable = true;
        # Whether the service is running as a docker container or a native nix service,
        # We should still be able to reach it at localhost:port
        url = "http://localhost";
        # Does this generalized approach work locally?
        # If so, it could be spun up on any VM and still work!
        #url = "http://${config.custom.world.hosts.proxmox.vms.media_vm.ip}";
        port = config.custom.world.services.radarr.port;
        openFirewall = true; # might not be necessary since it's local?
        environment = {
            # TODO do something here
            # This probably has to be manually configured via radarr first
            # Then we can make it into a secret...
            #API_KEY = config.sops.services.radarr.apiKey # TODO
            #API_KEY_FILE = config.sops.services.radarr.apiKey.path # TODO
        };
    };

    # Append Radarr scrape job to the existing Alloy config provided by the monitoring role
    environment.etc."alloy/config.alloy".text = lib.mkAfter ''
        // Scrape Radarr metrics from the exportarr-radarr exporter
        prometheus.scrape "exportarr_radarr" {
            targets = [
                {"__address__" = "localhost:${toString config.services.prometheus.exporters.exportarr-radarr.port}", "job" = "exportarr-radarr", "instance" = "${config.networking.hostName}:${toString config.services.prometheus.exporters.exportarr-radarr.port}"},
            ]
            scrape_interval = "30s"
            forward_to = [prometheus.remote_write.default.receiver]
        }
    '';
}