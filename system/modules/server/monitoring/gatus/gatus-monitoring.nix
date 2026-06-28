# Tell prometheus that it should monitor the metrics created by Gatus
{lib, config, ...}:
{
    services.prometheus.scrapeConfigs = [
      {
        job_name = "gatus";
        static_configs = [
          {
            targets = [
              "localhost:${toString config.custom.world.services.gatus.port}"
            ];
          }
        ];
      }
    ];
}