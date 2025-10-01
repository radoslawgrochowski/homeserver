{ config, lib, ... }:
{
  services.collabora-online = {
    enable = true;
    port = 9980;
    settings = {
      # Rely on reverse proxy for SSL
      ssl = {
        enable = false;
        termination = true;
      };

      # Listen on loopback interface only, and accept requests from ::1
      net = {
        listen = "loopback";
        post_allow.host = [ "::1" ];
      };

      # Restrict loading documents from WOPI Host
      storage.wopi = {
        "@allow" = true;
        host = [ config.services.nextcloud.hostName ];
      };

      # Set FQDN of server
      server_name = "collabora.nimbus.fard.pl";
    };
  };
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."${config.services.collabora-online.settings.server_name}" = {
      serverName = config.services.collabora-online.settings.server_name;
      forceSSL = true;
      enableACME = true;
      serverAliases = [ ];
      extraConfig = ''
        if ($host != "${config.services.collabora-online.settings.server_name}") {
          return 444;
        }
      '';
      locations."/" = {
        proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
        proxyWebsockets = true;
      };
    };
  };


  security.acme = {
    acceptTerms = true;
    certs."${config.services.collabora-online.settings.server_name}" = {
      email = "rg@fard.pl";
    };
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
    "127.0.0.1" = [ config.services.collabora-online.settings.server_name ];
    "::1" = [ config.services.collabora-online.settings.server_name ];
  };
}
