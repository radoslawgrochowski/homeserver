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
      recorder = { };
      history = { };
    };
    extraComponents = [
      "default_config"

      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/home-assistant/component-packages.nix
      "met"
      "google_assistant"
      "google_translate"
      "roborock"
      "tuya"
      "isal"
      "mqtt"

      # history
      "history"
      "history_stats"
      "recorder"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.nginx.virtualHosts."nimbus" = {
    locations."/hass" = {
      return = "301 $scheme://$http_host:8123";
    };
  };
}
