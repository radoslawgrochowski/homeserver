{ config, ... }:
let
  port = 9001;
in
{
  services.prometheus = {
    enable = true;
    port = port;
    scrapeConfigs = [
      {
        job_name = "node-exporter";
        static_configs = [
          { targets = [ "nimbus:${toString config.services.prometheus.exporters.node.port}" ]; }
          { targets = [ "fawkes:${toString config.services.prometheus.exporters.node.port}" ]; }
        ];
      }
      {
        job_name = "zfs-exporter";
        static_configs = [
          { targets = [ "nimbus:${toString config.services.prometheus.exporters.zfs.port}" ]; }
          { targets = [ "fawkes:${toString config.services.prometheus.exporters.zfs.port}" ]; }
        ];
      }
    ];
  };

  services.grafana.provision = {
    datasources.settings.datasources = [{
      name = "prometheus-nimbus";
      type = "prometheus";
      url = "http://nimbus:${toString port}";
    }];
    dashboards.settings.providers = [{
      name = "Node";
      options.path = ./grafana-dashboard-node.json;
    }];
  };
}
