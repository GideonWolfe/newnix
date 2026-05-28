{ lib, config, ... }:
let
  monitorHost = config.custom.world.hosts.monitor;
  prometheus = config.custom.world.services.prometheus;
in
{
  services.prometheus = { 
    # Server Settings
    enable = true;
    webExternalUrl = "${prometheus.protocol}://${prometheus.domain}";
    port = prometheus.port;
    extraFlags = [ 
      # Allow our agent nodes to push metrics to prometheus
      # instead of prometheus pulling only
      "--web.enable-remote-write-receiver" 
      # Require basic auth on all HTTP endpoints, including the
      # remote_write receiver. Hash lives in sops; see
      # system/modules/server/monitoring/secrets/secrets_monitoring.nix
      # for the template that renders this file.
      "--web.config.file=${config.sops.templates."prometheus-web.yml".path}"
    ];

    # NOTE: no `remoteWrite` here on purpose. Agents (alloy) push *into*
    # this prometheus via the receiver enabled above; we don't fan back
    # out anywhere. Re-add this block if you ever federate to another
    # prometheus instance.


    # Exporter Settings
    exporters.node = {
      enable = true;
      port = 9100;
      openFirewall = true;
      enabledCollectors = [
        # "arp"
        # "boottime"
        "cpu"
        "cpufreq"
        "diskstats"
        # "edac"
        # "entropy"
        "filefd"
        "filesystem"
        # "hwmon"
        # "ipvs"
        "meminfo"
        "netstat"
        # "nvme"
        "os"
        # "powersupplyclass"
        # "schedstat"
        # "sockstat"
        # "stat"
        # "thermal_zone"
        # "time"
        # "udp_queues"
        # "uname"
        # "vmstat"
        # "watchdog"
        # "interrupts"
        # "network_route"
        # "pcidevice"
        # "perf"
        # "processes"
        # "lnstat"
        # "tcpstat"
        "logind"
        "systemd"
        # "sysctl"
      ];
    };


    # Scrape configs - what Prometheus monitors
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.services.prometheus.exporters.node.port}"
            ];
          }
        ];
      }
      # TODO re-enable when back on VPS and running traefik
      # {
      #   job_name = "traefik";
      #   # shouldn't be needed
      #   # metrics_path = "/metrics";
      #   static_configs = [
      #     {
      #       targets = [
      #         "localhost:8082"
      #       ];
      #     }
      #   ];
      # }
    ]; 
  };

  # Open prometheus' main HTTP port so LAN agents can hit the
  # remote_write receiver (and so the homepage widget can scrape /api).
  networking.firewall.allowedTCPPorts = [ prometheus.port ];

  # Only enable traefik if running on same machine (ie prod) but not if in testing VM lab
  services.traefik.dynamicConfigOptions = lib.mkIf config.services.traefik.enable {
    http.routers.prometheus = {
      entryPoints = [ "http" "https" ];
      rule = "Host(`${prometheus.domain}`)";
      service = "prometheus";
      tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
      tls.certResolver = "myresolver";
    };

    http.services.prometheus = {
      loadBalancer = {
        passHostHeader = true;
        servers = [{ url = "http://${monitorHost.ip}:${toString prometheus.port}"; }];
      };
    };
  };
}