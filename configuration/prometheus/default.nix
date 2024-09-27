{ ... }:
let
  port = 9001;
  nodePort = 9002;
in
{

  services.prometheus = {
    enable = true;
    port = port;
    scrapeConfigs = [{
      job_name = "node-exporter";
      static_configs = [{ targets = [ "localhost:${toString nodePort}" ]; }];
    }];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = nodePort;
      };
    };
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
