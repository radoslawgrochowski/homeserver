{ pkgs, ... }: {
  services.home-assistant = {
    enable = true;
    package = pkgs.unstable.home-assistant;
    config = {
      homeassistant = {
        auth_providers = [{
          type = "trusted_networks";
          trusted_networks = [
            "0.0.0.0/0"
            "::/0"
          ];
          allow_bypass_login = true;
        }];
      };
      "automation manual" = import ./temperature-alerts.nix;
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
    ];

    customComponents = [
      (pkgs.callPackage ./gree.nix { })
    ];
  };


  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.nginx.virtualHosts."nimbus" = {
    locations."/hass" = {
      return = "301 $scheme://$http_host:8123";
    };
  };
}
