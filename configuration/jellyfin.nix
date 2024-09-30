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

  services.nginx.virtualHosts."nimbus.local" = {
    locations."/jellyfin" = {
      return = "301 http://nimbus.local:8096";
    };
  };
}

