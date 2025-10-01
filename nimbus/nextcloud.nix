{ pkgs, config, lib, ... }:
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
      inherit (config.services.nextcloud.package.packages.apps) memories recognize richdocuments;
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

      # this enables thumbnails for videos
      enabledPreviewProviders = [
        "OC\\Preview\\BMP"
        "OC\\Preview\\GIF"
        "OC\\Preview\\JPEG"
        "OC\\Preview\\Krita"
        "OC\\Preview\\MarkDown"
        "OC\\Preview\\MP3"
        "OC\\Preview\\OpenDocument"
        "OC\\Preview\\PNG"
        "OC\\Preview\\TXT"
        "OC\\Preview\\XBitmap"

        "OC\\Preview\\Movie"
        "OC\\Preview\\HEIC"
      ];

      overwrite.cli.url = "https://${config.services.nextcloud.hostName}";
    };
    config = {
      dbtype = "pgsql";
      adminuser = "admin";
      adminpassFile = config.age.secrets.nextcloud-admin-password.path;
    };
    maxUploadSize = "16G";
    phpOptions."opcache.interned_strings_buffer" = "16";
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

      add_header X-XSS-Protection "1; mode=block";
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

  systemd.services.nextcloud-config =
    let
      inherit (config.services.nextcloud) occ;
    in
    {
      wantedBy = [ "multi-user.target" ];
      after = [ "nextcloud-setup.service" ];
      script = ''
        ${occ}/bin/nextcloud-occ config:system:set maintenance_window_start --type=integer --value=6
      '';
      serviceConfig = { Type = "oneshot"; };
    };

  systemd.services.nextcloud-config-collabora =
    let
      inherit (config.services.nextcloud) occ;
      wopi_url = "http://[::1]:${toString config.services.collabora-online.port}";
      public_wopi_url = "https://${config.services.collabora-online.settings.server_name}";
      wopi_allowlist = lib.concatStringsSep "," [ "127.0.0.1" "::1" ];
    in
    {
      wantedBy = [ "multi-user.target" ];
      after = [ "nextcloud-setup.service" "coolwsd.service" ];
      requires = [ "coolwsd.service" ];
      script = ''
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
        ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
        ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
        ${occ}/bin/nextcloud-occ richdocuments:setup
      '';
      serviceConfig = { Type = "oneshot"; };
    };

  networking.hosts = {
    "127.0.0.1" = [ config.services.nextcloud.hostName ];
    "::1" = [ config.services.nextcloud.hostName ];
  };
}

