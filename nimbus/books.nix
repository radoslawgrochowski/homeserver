{ pkgs, config, ... }:
{
  systemd.tmpfiles.rules = [
    "d /media/books 774 media media - -"
    "d /media/calibre-library 774 media media - -"
    "d /var/lib/shelfmark 0750 media media - -"
    "d /var/lib/cwa 0750 media media - -"
  ];

  virtualisation.oci-containers.containers.shelfmark = {
    image = "ghcr.io/calibrain/shelfmark:v1.2.1";
    extraOptions = [ "--network=host" ];
    volumes = [
      "/var/lib/shelfmark/config:/config"
      "/media/books:/books"
      "/media/downloads:/media/downloads"
    ];
    environment = {
      FLASK_PORT = "8084";
      INGEST_DIR = "/books";
      PUID = "993";
      PGID = "992";
      TZ = config.time.timeZone;
    };
  };

  virtualisation.oci-containers.containers.calibre-web-automated = {
    image = "crocodilestick/calibre-web-automated:v4.0.6";
    extraOptions = [ "--network=host" ];
    volumes = [
      "/var/lib/cwa/config:/config"
      "/media/books:/cwa-book-ingest"
      "/media/calibre-library:/calibre-library"
    ];
    environment = {
      PUID = "993";
      PGID = "992";
      TZ = config.time.timeZone;
      CWA_PORT_OVERRIDE = "8082";
    };
  };

  networking.firewall.allowedTCPPorts = [
    8082
    8084
  ];

  services.nginx.virtualHosts."nimbus.fard.pl" = {
    locations."/shelfmark" = {
      return = "301 $scheme://$http_host:8084";
    };
    locations."/books" = {
      return = "301 $scheme://$http_host:8082";
    };
  };
}
