{ config, lib, ... }: {
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

  services.recyclarr = {
    enable = true;
    configuration = {
      radarr = {
        radarr-main = {
          api_key = {
            _secret = "/run/credentials/recyclarr.service/radarr-api_key";
          };
          base_url = "http://localhost:7878";
          delete_old_custom_formats = true;
          replace_existing_custom_formats = true;
          include = [
            { template = "radarr-quality-definition-movie"; }
            { template = "radarr-quality-profile-remux-web-1080p"; }
            { template = "radarr-custom-formats-remux-web-1080p"; }
            { template = "radarr-quality-profile-remux-web-2160p"; }
            { template = "radarr-custom-formats-remux-web-2160p"; }
          ];
          custom_formats = [
            # Audio
            {
              trash_ids = [
                "496f355514737f7d83bf7aa4d24f8169" # TrueHD Atmos
                "2f22d89048b01681dde8afe203bf2e95" # DTS X
                "417804f7f2c4308c1f4c5d380d4c4475" # ATMOS (undefined)
                "1af239278386be2919e1bcee0bde047e" # DD+ ATMOS
                "3cafb66171b47f226146a0770576870f" # TrueHD
                "dcf3ec6938fa32445f590a4da84256cd" # DTS-HD MA
                "a570d4a0e56a2874b64e5bfa55202a1b" # FLAC
                "e7c2fcae07cbada050a0af3357491d7b" # PCM
                "8e109e50e0a0b83a5098b056e13bf6db" # DTS-HD HRA
                "185f1dd7264c4562b9022d963ac37424" # DD+
                "f9f847ac70a0af62ea4a08280b859636" # DTS-ES
                "1c1a4c5e823891c75bc50380a6866f73" # DTS
                "240770601cc226190c367ef59aba7463" # AAC
                "c2998bd0d90ed5621d8df281e839436e" # DD
              ];
              assign_scores_to = [
                { name = "Remux + WEB 1080p"; }
                { name = "Remux + WEB 2160p"; }
              ];
            }

            # Movie Versions
            {
              trash_ids = [
                "0f12c086e289cf966fa5948eac571f44" # Hybrid
                "570bc9ebecd92723d2d21500f4be314c" # Remaster
                "eca37840c13c6ef2dd0262b141a5482f" # 4K Remaster
                "e0c07d59beb37348e975a930d5e50319" # Criterion Collection
                "9d27d9d2181838f76dee150882bdc58c" # Masters of Cinema
                "db9b4c4b53d312a3ca5f1378f6440fc9" # Vinegar Syndrome
                "957d0f44b592285f26449575e8b1167e" # Special Edition
                "eecf3a857724171f968a66cb5719e152" # IMAX
                "9f6cbff8cfe4ebbc1bde14c7b7bec0de" # IMAX Enhanced
              ];
              assign_scores_to = [
                { name = "Remux + WEB 1080p"; }
                { name = "Remux + WEB 2160p"; }
              ];
            }

            {
              trash_ids = [
                "923b6abef9b17f937fab56cfcf89e1f1" # blocks DV without fallback
              ];
              assign_scores_to = [
                { name = "Remux + WEB 1080p"; }
                { name = "Remux + WEB 2160p"; }
              ];
            }
          ];
          quality_definition = {
            type = "sqp-streaming";
            preferred_ratio = 0.0;
          };
        };
      };
      sonarr = {
        sonarr-main = {
          api_key = {
            _secret = "/run/credentials/recyclarr.service/sonarr-api_key";
          };
          base_url = "http://localhost:8989";
          delete_old_custom_formats = true;
          replace_existing_custom_formats = true;
          include = [
            { template = "sonarr-quality-definition-series"; }
            { template = "sonarr-v4-quality-profile-web-1080p-alternative"; }
            { template = "sonarr-v4-custom-formats-web-1080p"; }
            { template = "sonarr-v4-quality-profile-web-2160p-alternative"; }
            { template = "sonarr-v4-custom-formats-web-2160p"; }
          ];
          custom_formats = [
            {
              trash_ids = [
                "9b27ab6498ec0f31a3353992e19434ca" # blocks DV without fallback
              ];
              assign_scores_to = [
                { name = "WEB-1080p"; }
                { name = "WEB-2160p"; }
              ];
            }
            {
              trash_ids = [
                "2016d1676f5ee13a5b7257ff86ac9a93 " # block SDR
              ];
              assign_scores_to = [
                { name = "WEB-1080p"; }
                { name = "WEB-2160p"; }
              ];
            }
          ];

          quality_definition = {
            type = "series";
            preferred_ratio = 0.0;
          };
        };
      };
    };
    group = "media";
    user = "media";
  };

  systemd.services.recyclarr.serviceConfig.LoadCredential = [
    "radarr-api_key:${config.age.secrets.radarr-api-key.path}"
    "sonarr-api_key:${config.age.secrets.sonarr-api-key.path}"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "unrar"
  ];

  services.nginx.virtualHosts."nimbus" = {
    locations."/radarr" = {
      return = "301 $scheme://$http_host:7878";
    };
    locations."/sonarr" = {
      return = "301 $scheme://$http_host:8989";
    };
    locations."/prowlarr" = {
      return = "301 $scheme://$http_host:9696";
    };
    locations."/sabnzbd" = {
      return = "301 $scheme://$http_host:8800";
    };
    locations."/bazarr" = {
      return = "301 $scheme://$http_host:6767";
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
