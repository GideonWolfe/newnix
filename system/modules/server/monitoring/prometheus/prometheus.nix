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
      # Allow our devices to push metrics to prometheus
      # instead of prometheus pulling only
      "--web.enable-remote-write-receiver" 
      # TODO
      #https://prometheus.io/docs/guides/basic-auth/
      # "--web.config.file=/etc/prometheus/web.yml"
    ];

    # TODO test
    remoteWrite = [{
        url = "https://${prometheus.domain}/api/prom/push";
        basic_auth = {
            username = config.sops.secrets."prometheus/push_user".value;
            password_file = config.sops.secrets."prometheus/push_password".path;
        };
    }];


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
      {
        job_name = "traefik";
        # shouldn't be needed
        # metrics_path = "/metrics";
        static_configs = [
          {
            targets = [
              "localhost:8082"
            ];
          }
        ];
      }
    ]; 
  };

  services.traefik.dynamicConfigOptions.http.routers.prometheus = {
    entryPoints = [ "http" "https" ];
    rule = "Host(`${prometheus.domain}`)";
    service = "prometheus";
    tls.domains = [{ main = "*.gideonwolfe.xyz"; }];
    tls.certResolver = "myresolver";
  };

  services.traefik.dynamicConfigOptions.http.services.prometheus = {
      loadBalancer = {
        passHostHeader = true;
        servers = [{ url = "http://${monitorHost.ip}:${toString prometheus.port}"; }];
      };
   };
}