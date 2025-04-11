{ config, ... }: {
  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = true;
        settings.allow_anonymous = true;
      }
    ];
  };
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      mqtt = {
        server = "mqtt://localhost:1883";
      };
      serial = {
        adapter = "ember";
        port = "/dev/ttyUSB0";
      };
      homeassistant = config.services.home-assistant.enable;
      frontend = {
        enabled = true;
        host = "0.0.0.0";
        port = 8083;
      };
      devices = {
        "0x08ddebfffef1a9f8" = { friendly_name = "bedroom/sensor"; };
        "0x44e2f8fffe21cb74" = { friendly_name = "bedroom/button"; };
      };
    };
  };


  networking.firewall.allowedTCPPorts = [ config.services.zigbee2mqtt.settings.frontend.port ];

  services.nginx.virtualHosts."nimbus" = {
    locations."/z2m" = {
      return = "301 $scheme://$http_host:8083";
    };
  };
}
