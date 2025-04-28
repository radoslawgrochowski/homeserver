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
      "automation manual" = [ ];
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
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.nginx.virtualHosts."nimbus" = {
    locations."/hass" = {
      return = "301 $scheme://$http_host:8123";
    };
  };
}
