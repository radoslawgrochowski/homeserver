{ pkgs, ... }: {
  services.home-assistant = {
    enable = true;
    config = { };
    package = (pkgs.home-assistant.override {
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/home-assistant/component-packages.nix
      extraComponents = [
        "default_config"
        "met"
        "roborock"
        "google_translate"
      ];
    });
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  services.nginx.virtualHosts."nimbus.local" = {
    locations."/hass" = {
      return = "301 http://nimbus.local:8123";
    };
  };
}
