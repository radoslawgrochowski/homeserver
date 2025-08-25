{ pkgs, config, ... }:
{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud31;
    database.createLocally = true;
    configureRedis = true;
    datadir = "/tank/nextcloud-data";
    hostName = "nextcloud.nimbus.fard.pl";
    https = true;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) memories recognize;
    };
    extraAppsEnable = true;
    settings = {
      allowed_admin_ranges = [
        "192.168.0.0/16"
        "fd00::/8"
      ];

      log_type = "file";
      logfile = "/var/log/nextcloud/nextcloud.log";
      loglevel = 2;
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

  systemd.tmpfiles.rules = [
    "d /var/log/nextcloud 0750 nextcloud nextcloud -"
  ];
  environment.etc."fail2ban/filter.d/nextcloud.conf".text = ''
    [Definition]
    _groupsre = (?:(?:,?\s*"\w+":(?:"[^"]+"|\w+))*)
    failregex = ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Login failed:
                ^\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Trusted domain error.
    datepattern = ,?\s*"time"\s*:\s*"%%Y-%%m-%%d[T ]%%H:%%M:%%S(%%z)?"
  '';

  services.nginx.virtualHosts.${config.services.nextcloud.hostName} = {
    serverName = config.services.nextcloud.hostName;
    forceSSL = true;
    enableACME = true;
    serverAliases = [ ];
    extraConfig = ''
      if ($host != "${config.services.nextcloud.hostName}") {
        return 444;
      }
    '';
  };

  security.acme = {
    acceptTerms = true;
    certs."${config.services.nextcloud.hostName}" = {
      email = "rg@fard.pl";
    };
  };

  services.fail2ban.jails.nextcloud = {
    settings = {
      enabled = true;
      port = "80,443";
      logpath = "/var/log/nextcloud/nextcloud.log";
      filter = "nextcloud";
      maxretry = 3;
      bantime = "86400";
      findtime = "43200";
    };
  };
}

