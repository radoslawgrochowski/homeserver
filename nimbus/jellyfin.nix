{ pkgs, ... }: {
  nixpkgs.overlays = [
    (
      final: prev:
        {
          jellyfin-web = prev.jellyfin-web.overrideAttrs (finalAttrs: previousAttrs: {
            installPhase = ''
              runHook preInstall
              sed -i "s#</head>#<script src=\"configurationpage?name=skip-intro-button.js\"></script></head>#" dist/index.html
              mkdir -p $out/share
              cp -a dist $out/share/jellyfin-web
              runHook postInstall
            '';
          });
        }
    )
  ];

  services.jellyfin = {
    enable = true;
    user = "media";
    group = "media";
    openFirewall = true;
  };

  users.users.jellyfin = {
    isSystemUser = true;
    group = "media";
    extraGroups = [ "render" "video" "output" ];
  };

  environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];

  services.nginx.virtualHosts."nimbus.fard.pl" = {
    locations."/jellyfin" = {
      return = "301 $scheme://$http_host:8096";
    };
  };
}

