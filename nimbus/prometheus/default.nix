{ config, ... }:
let
  port = 9001;
in
{
  services.prometheus = {
    enable = true;
    port = port;
    scrapeConfigs = [{
      job_name = "node-exporter";
      static_configs = [
        { targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ]; }
        { targets = [ "fawkes:9100" ]; }
      ];
    }];
  };

  services.grafana.provision = {
    datasources.settings.datasources = [{
      name = "node-exporter";
      type = "prometheus";
      url = "http://127.0.0.1:${toString port}";
    }];
    dashboards.settings.providers = [{
      name = "Node";
      options.path = ./grafana-dashboard-node.json;
    }];
  };
}
