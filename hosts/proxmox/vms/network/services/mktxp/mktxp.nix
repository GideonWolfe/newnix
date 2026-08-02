{ config, pkgs, ... }:
let
    port = 49090;
    hosts = config.custom.world.hosts;
    cfgDir = "/run/mktxp";

    # System-level config (_mktxp.conf). No secrets, so it can live in the store.
    systemConf = pkgs.writeText "_mktxp.conf" ''
        [MKTXP]
            listen = '0.0.0.0:${toString port}'
            socket_timeout = 5

            initial_delay_on_failure = 120
            max_delay_on_failure = 900
            delay_inc_div = 5

            bandwidth = False
            bandwidth_test_interval = 600
            minimal_collect_interval = 5

            verbose_mode = False

            fetch_routers_in_parallel = False
            max_worker_threads = 5
            max_scrape_duration = 10
            total_max_scrape_duration = 30

            compact_default_conf_values = False
    '';

    # Assemble the cfg dir at runtime: the sops-rendered device config plus the
    # static system config. mktxp expects both files in a single --cfg-dir.
    prepare = pkgs.writeShellScript "mktxp-prepare" ''
        set -eu
        ${pkgs.coreutils}/bin/install -m0640 \
            ${config.sops.templates."mktxp.conf".path} ${cfgDir}/mktxp.conf
        ${pkgs.coreutils}/bin/install -m0640 \
            ${systemConf} ${cfgDir}/_mktxp.conf
    '';
in
{
    # Render mktxp.conf with real credentials at runtime (kept out of the Nix
    # store). Reuses the same sops secrets as the base mikrotik exporter.
    sops.templates."mktxp.conf" = {
        group = "mktxp-secrets";
        mode = "0440";
        content = ''
            [rb5009]
                hostname = ${hosts.router.ip}
                username = ${config.sops.placeholder."mikrotik/rb5009/username"}
                password = ${config.sops.placeholder."mikrotik/rb5009/password"}

            [hapax2]
                hostname = ${hosts.access_point.ip}
                username = ${config.sops.placeholder."mikrotik/hapax2/username"}
                password = ${config.sops.placeholder."mikrotik/hapax2/password"}

            [default]
                enabled = True
                port = 8728
                use_ssl = False
                plaintext_login = True
                dhcp = True
                dhcp_lease = True
                route = True
                pool = True
                # bgp disabled: neither device runs BGP.
                bgp = False
        '';
    };

    # mktxp runs as a systemd DynamicUser, which can't read the root-owned sops
    # template directly. Own the rendered file by a dedicated group and add the
    # service to it via SupplementaryGroups.
    users.groups.mktxp-secrets = { };

    systemd.services.mktxp = {
        description = "MKTXP Mikrotik RouterOS Prometheus exporter";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        # mktxp shells out to `which`, which isn't on the minimal DynamicUser PATH.
        path = [ pkgs.which ];
        serviceConfig = {
            DynamicUser = true;
            SupplementaryGroups = [ "mktxp-secrets" ];
            RuntimeDirectory = "mktxp";
            RuntimeDirectoryMode = "0750";
            ExecStartPre = prepare;
            ExecStart = "${pkgs.mktxp}/bin/mktxp --cfg-dir ${cfgDir} export";
            Restart = "on-failure";
        };
    };

    networking.firewall.allowedTCPPorts = [ port ];

    # Have the local Alloy instance scrape this exporter automatically.
    custom.monitoring.alloy.extraConfigs = [
        ''
      // Scrape MikroTik metrics from the local mktxp exporter
      prometheus.scrape "mktxp" {
        targets = [
          {"__address__" = "localhost:${toString port}", "job" = "mktxp", "instance" = "${config.networking.hostName}:${toString port}"},
        ]
        scrape_interval = "60s"
        forward_to = [prometheus.remote_write.default.receiver]
      }
        ''
    ];
}
