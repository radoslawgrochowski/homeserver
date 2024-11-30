{ pkgs, ... }: {
  services.home-assistant = {
    enable = true;
    config = { };
    extraComponents = [
      "default_config"

      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/home-assistant/component-packages.nix
      "met"
      "google_assistant"
      "google_translate"
      "roborock"
      "tuya"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.nginx.virtualHosts."nimbus.local" = {
    locations."/hass" = {
      return = "301 http://nimbus.local:8123";
    };
  };
}
