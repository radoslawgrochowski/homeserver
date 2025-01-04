{ lib, ... }: {
  systemd.tmpfiles.rules = [
    "d /media/movies 774 media media - -"
    "d /media/tv 774 media media - -"
    "d /media/downloads 774 media media - -"
    "d /media/downloads/incomplete 774 media media - -"
    "d /media/downloads/complete 774 media media - -"
  ];
  services.radarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    user = "media";
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    user = "media";
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # FIXME config does not work properly
  # need to edit /var/lib/sabnzbd/sabnzbd.ini manually:
  #   change host to 0.0.0.0 
  #   change port to 8800 
  # and then reload
  services.sabnzbd = {
    enable = true;
    group = "media";
    user = "media";
  };
  networking.firewall.allowedTCPPorts = [ 8800 ];

  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "media";
    user = "media";
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "unrar"
  ];

  services.nginx.virtualHosts."nimbus.local" = {
    locations."/radarr" = {
      return = "301 http://nimbus.local:7878";
    };
    locations."/sonarr" = {
      return = "301 http://nimbus.local:8989";
    };
    locations."/prowlarr" = {
      return = "301 http://nimbus.local:9696";
    };
    locations."/sabnzbd" = {
      return = "301 http://nimbus.local:8800";
    };
    locations."/bazarr" = {
      return = "301 http://nimbus.local:6767";
    };
  };

  # FIXME 
  nixpkgs.config.permittedInsecurePackages = [
    "aspnetcore-runtime-6.0.36"
    "aspnetcore-runtime-wrapped-6.0.36"
    "dotnet-sdk-6.0.428"
    "dotnet-sdk-wrapped-6.0.428"
  ];
}
