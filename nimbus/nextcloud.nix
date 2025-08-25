{ pkgs, config, ... }:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    database.createLocally = true;
    configureRedis = true;
    datadir = "/tank/nextcloud-data";
    hostName = "nextcloud.nimbus.fard.pl";
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) memories recognize;
    };
    extraAppsEnable = true;
    settings = {
      overwriteprotocol = "http";
      overwritehost = config.services.nextcloud.hostName;
      overwritewebroot = "/";
      overwrite.cli.url = "${config.services.nextcloud.settings.overwriteprotocol}://${config.services.nextcloud.hostName}/";
      htaccess.RewriteBase = "/";
    };
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = config.age.secrets.nextcloud-admin-password.path;
    };
    maxUploadSize = "16G";
  };

  services.blocky.settings.customDNS.mapping."${config.services.nextcloud.hostName}" =
    (builtins.elemAt config.networking.interfaces.eth0.ipv4.addresses 0).address;
}

