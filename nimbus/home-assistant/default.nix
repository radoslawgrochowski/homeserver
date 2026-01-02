{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant;

    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/home-assistant/component-packages.nix
    extraComponents = [
      "default_config"

      "google_translate"
      "history"
      "history_stats"
      "isal"
      "mqtt"
      "recorder"
      "roborock"
      "met"
    ];

    customComponents = [
      (pkgs.callPackage ./browser-mod.nix { })
      (pkgs.callPackage ./gree.nix { })
      (pkgs.callPackage ./ztm.nix { })
    ];

    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      (pkgs.callPackage ./bubble-card.nix { })
      clock-weather-card
      card-mod
    ];

    config = {
      homeassistant = {
        auth_providers = [
          {
            type = "trusted_networks";
            trusted_networks = [
              "0.0.0.0/0"
              "::/0"
            ];
            allow_bypass_login = true;
          }
          { type = "homeassistant"; }
        ];
      };
      "automation manual" =
        (import ./temperature-alerts.nix { inherit config lib; })
        ++ (import ./grafana-alerts.nix)
        ++ (import ./humidity-alerts.nix { inherit config lib; })
        ++ (import ./roborock.nix { inherit lib; }).automation
        ++ (import ./light-switches.nix { inherit lib; }).automation;
      input_datetime = (import ./roborock.nix { inherit lib; }).input_datetime;
      script =
        (import ./roborock.nix { inherit lib; }).script
        // (import ./light-switches.nix { inherit lib; }).script;
      light = (import ./light-groups.nix { inherit lib; }).light;
      "automation ui" = "!include automations.yaml";
      assist_pipeline = { };
      dhcp = { };
      history = { };
      homeassistant_alerts = { };
      logbook = { };
      mobile_app = { };
      recorder = { };
      ssdp = { };
      zeroconf = { };
      climate = [
        {
          name = "living-room/ac";
          platform = "gree";
          host = "192.168.0.112";
          mac = "C0:39:37:A1:AE:5C";
        }
      ];
      frontend = {
        extra_module_url = [
          "/local/nixos-lovelace-modules/card-mod.js"
        ];
      };

      sensor = [
        {
          platform = "ztm";
          api_key = "!secret api-um-warszawa-key";
          lines =
            let
              mkLines =
                stop_id: numbers: stop_numbers:
                builtins.concatMap (
                  num:
                  builtins.map (stop_num: {
                    number = num;
                    inherit stop_id;
                    stop_number = stop_num;
                  }) stop_numbers
                ) numbers;
            in
            mkLines 5068 [ 24 23 50 20 ] [ "03" "04" ]
            ++ mkLines 5124 [ 103 ] [ "01" "02" ]
            ++ mkLines 5124 [ 136 ] [ "03" ]
            ++ mkLines 5124 [ 106 ] [ "05" ];
        }
      ];
    };
  };

  age.secrets.home-assistant-secrets = {
    file = ../../secrets/home-assistant-secrets.age;
    path = "${config.services.home-assistant.configDir}/secrets.yaml";
    owner = config.systemd.services.home-assistant.serviceConfig.User;
    group = config.systemd.services.home-assistant.serviceConfig.Group;
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.nginx.virtualHosts."nimbus.fard.pl" = {
    locations."/hass" = {
      return = "301 $scheme://$http_host:8123";
    };
  };
}
