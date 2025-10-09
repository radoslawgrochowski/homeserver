{ pkgs, lib, ... }:
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
      (pkgs.callPackage ./gree.nix { })
    ];

    customLovelaceModules = [
      (pkgs.callPackage ./bubble-card.nix { })
      pkgs.home-assistant-custom-lovelace-modules.clock-weather-card
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
        ];
      };
      "automation manual" =
        (import ./temperature-alerts.nix)
        ++ (import ./grafana-alerts.nix)
        ++ (import ./roborock.nix { inherit lib; }).automation;
      input_datetime = (import ./roborock.nix { inherit lib; }).input_datetime;
      script = (import ./roborock.nix { inherit lib; }).script;
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
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.nginx.virtualHosts."nimbus.fard.pl" = {
    locations."/hass" = {
      return = "301 $scheme://$http_host:8123";
    };
  };
}
