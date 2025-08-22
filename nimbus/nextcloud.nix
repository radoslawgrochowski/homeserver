{ pkgs, config, ... }:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    database.createLocally = true;
    configureRedis = true;
    datadir = "/tank/nextcloud-data";
    hostName = "127.0.0.1";
    settings = {
      overwriteprotocol = "http";
      overwritehost = "nimbus.local";
      overwritewebroot = "/nextcloud";
      overwrite.cli.url = "http://nimbus.local/nextcloud/";
      htaccess.RewriteBase = "/nextcloud";
      trusted_domains = [
        "nimbus"
        "nimbus.fard.pl"
        "192.168.0.8"
        "nimbus.tail36fc5c.ts.net"
      ];
    };
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = config.age.secrets.nextcloud-admin-password.path;
    };
    maxUploadSize = "16G";
  };

  services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [{ addr = "127.0.0.1"; port = 8082; }];

  services.nginx.virtualHosts."nimbus" = {
    locations."/nextcloud/" = {
      priority = 9999;
      extraConfig = ''
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_set_header X-Forwarded-Proto http;
        proxy_set_header Host $host;
        proxy_pass http://127.0.0.1:8082/; # tailing / is important!
        proxy_cache_bypass $http_upgrade;
        proxy_redirect off;
        client_max_body_size 1G;
      '';
    };
  };
}

