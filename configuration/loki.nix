{ ... }: {
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = { http_listen_port = 3100; };
      common = {
        path_prefix = "/tmp/loki";
        storage.filesystem = { chunks_directory = "/tmp/loki/chunks"; rules_directory = "/tmp/loki/rules"; };
        replication_factor = 1;
        ring = {
          instance_addr = "127.0.0.1";
          kvstore.store = "inmemory";
        };
      };
      schema_config.configs = [
        { from = "2020-10-24"; store = "tsdb"; object_store = "filesystem"; schema = "v13"; index = { prefix = "index_"; period = "24h"; }; }
      ];
      analytics.reporting_enabled = false;
    };
  };

  services.grafana.provision = {
    datasources.settings.datasources = [{
      name = "nimbus-loki";
      type = "loki";
      url = "http://127.0.0.1:3100";
    }];
  };
}