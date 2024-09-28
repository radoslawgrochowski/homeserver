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
      "auth" = {
        disable_login_form = true;
      };
      "auth.anonymous" = {
        enabled = true;
        org_name = "Main Org.";
        org_role = "Editor";
      };
      "auth.basic" = {
        enabled = false;
      };
      security = {
        allow_embedding = true;
      };
    };

    provision.enable = true;
  };

  services.nginx.virtualHosts."nimbus.local" = {
    locations."/grafana/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };

}
