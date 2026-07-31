{ config, lib, ... }:
let
    mikrotik = config.services.prometheus.exporters.mikrotik;
in
{
    services.prometheus.exporters.mikrotik = {
        enable = true;
        #port = 9189;
        openFirewall = true;
        # Use a sops-rendered config file so device credentials stay out of
        # the world-readable Nix store. The template lives in the secrets
        # module; `configFile` and `configuration` are mutually exclusive.
        configFile = config.sops.templates."mikrotik-exporter-config.yaml".path;
    };

    # The exporter runs as a systemd DynamicUser, so it can't read the
    # root-owned sops template. Own the rendered file by a dedicated group
    # and add the service to it (SupplementaryGroups works with DynamicUser).
    # NB: the DynamicUser/group is itself named `mikrotik-exporter`, so this
    # group must use a different name to avoid a collision.
    users.groups.mikrotik-exporter-secrets = {};
    sops.templates."mikrotik-exporter-config.yaml" = {
        group = "mikrotik-exporter-secrets";
        mode = "0440";
    };
    systemd.services.prometheus-mikrotik-exporter.serviceConfig.SupplementaryGroups =
        [ "mikrotik-exporter-secrets" ];

    # Have the local Alloy instance scrape this exporter automatically
    custom.monitoring.alloy.extraConfigs = [
        ''
      // Scrape MikroTik metrics from the local mikrotik exporter
      prometheus.scrape "mikrotik_exporter" {
        targets = [
          {"__address__" = "localhost:${toString mikrotik.port}", "job" = "mikrotik", "instance" = "${config.networking.hostName}:${toString mikrotik.port}"},
        ]
        scrape_interval = "60s"
        forward_to = [prometheus.remote_write.default.receiver]
      }
        ''
    ];
}