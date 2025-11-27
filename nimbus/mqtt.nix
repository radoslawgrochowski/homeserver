{ config, ... }:
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
      devices = {
        "0x44e2f8fffe21cb74" = {
          friendly_name = "bedroom/button";
        };
        "0xa4c138af4f0aef38" = {
          friendly_name = "bedroom/light-switch";
        };
        "0x94ec32fffeff21f7" = {
          friendly_name = "bedroom/plug";
        };
        "0xd44867fffe150cc2" = {
          friendly_name = "bedroom/main-light";
        };
        "0x08b95ffffed9f8b5" = {
          friendly_name = "bedroom/control";
        };
        "0x44e2f8fffe0149d0" = {
          friendly_name = "bedroom/led-strip";
        };
        "0x08ddebfffef1a9f8" = {
          friendly_name = "living-room/sensor";
        };
        "0x0c2a6ffffe22d8e5" = {
          friendly_name = "living-room/light";
        };
        "0x0ceff6fffe675963" = {
          friendly_name = "loggia/sensor";
        };
        "0x842712fffe380961" = {
          friendly_name = "office/sensor";
        };
        "0x8c8b48fffef12834" = {
          friendly_name = "living-room/bulb1";
        };
        "0x8c8b48fffedd1d4f" = {
          friendly_name = "living-room/bulb2";
        };
        "0x94a081fffe706960" = {
          friendly_name = "living-room/bulb3";
        };
        "0x94a081fffe0f26f0" = {
          friendly_name = "kitchen/bulb1";
        };
        "0x8c8b48fffef12eac" = {
          friendly_name = "kitchen/bulb2";
        };
        "0x8c8b48fffec49d39" = {
          friendly_name = "hall/bulb1";
        };
        "0x94a081fffeac2137" = {
          friendly_name = "hall/bulb2";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ config.services.zigbee2mqtt.settings.frontend.port ];

  services.nginx.virtualHosts."nimbus.fard.pl" = {
    locations."/z2m" = {
      return = "301 $scheme://$http_host:8083";
    };
  };
}
