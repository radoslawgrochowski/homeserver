{ pkgs, ... }: {
  services.jellyfin = {
    enable = true;
    user = "media";
    group = "media";
    openFirewall = true;
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.nginx.virtualHosts."nimbus" = {
    locations."/jellyfin" = {
      return = "301 $scheme://$http_host:8096";
    };
  };
}

