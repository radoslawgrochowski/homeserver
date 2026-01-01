{ config, lib, ... }:

{
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
      devices = lib.listToAttrs (
        map (device: {
          name = device.ieee;
          value = {
            friendly_name = device.name;
          };
        }) config.devices.zigbee
      );
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.zigbee2mqtt.settings.frontend.port ];

  services.nginx.virtualHosts."nimbus.fard.pl" = {
    locations."/z2m" = {
      return = "301 $scheme://$http_host:8083";
    };
  };
}
