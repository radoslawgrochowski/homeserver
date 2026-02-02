{ ... }:
let
  httpPort = 4111;
in
# see: https://github.com/notohh/snowflake/blob/24c9c4d46344cefc1ae96671061830226d48f35f/hosts/haru/services/blocky.nix#L104
{
  services.blocky = {
    enable = true;
    settings = {
      connectIPVersion = "dual";
      ports = {
        dns = 53;
        http = httpPort;
      };

      upstreams = {
        groups.default = [
          "https://dns.quad9.net/dns-query"
          "https://one.one.one.one/dns-query"
          "https://doh-de.blahdns.com/dns-query"
          "https://dns.google/dns-query"
        ];
        strategy = "parallel_best";
      };

      bootstrapDns = {
        upstream = "https://one.one.one.one/dns-query";
        ips = [
          "1.1.1.1"
          "1.0.0.1"
        ];
      };

      caching = {
        minTime = "5m";
        maxTime = "60m";
        prefetching = true;
      };

      blocking = {
        denylists.ads = [
          "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/domains/pro.txt"
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
        ];
        clientGroupsBlock.default = [ "ads" ];
      };

      customDNS = {
        customTTL = "1h";
        mapping = {
          "nimbus.fard.pl" = "192.168.0.8";
        };
      };

      prometheus = {
        enable = true;
        path = "/metrics";
      };
    };

  };

  networking.firewall.allowedTCPPorts = [
    53
    httpPort
  ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.grafana.provision.dashboards.settings.providers = [
    {
      name = "Blocky";
      options.path = ./grafana-dashboard-blocky.json;
    }
  ];

  services.prometheus = {
    scrapeConfigs = [
      {
        job_name = "blocky";
        static_configs = [ { targets = [ "localhost:${toString httpPort}" ]; } ];
      }
    ];
  };
}
