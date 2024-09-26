{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 8101;
        domain = "nimbus.local";
        root_url = "http://nimbus.local/grafana/";
        serve_from_sub_path = true;
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "prometheus-node"; # name is mandatory but I can leave it out
          type = "prometheus";
          url = "http://127.0.0.1:9001"; # TODO make configurable
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Node stats";
          folder = "Common";
          options.path = ./dashboards/node-exporter.json;
        }
      ];
    };
  };

  services.nginx.virtualHosts."nimbus.local" = {
    locations."/grafana/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

}
