{ config, lib, ... }:

let
  cfg = config.devices;

  deviceType = lib.types.submodule (
    { config, ... }:
    {
      options = {
        ieee = lib.mkOption {
          type = lib.types.str;
          description = "IEEE 802.15.4 address (Zigbee MAC address)";
          example = "0x8c8b48fffef12834";
        };

        room = lib.mkOption {
          type = lib.types.str;
          description = "Room location";
          example = "living_room";
        };

        type = lib.mkOption {
          type = lib.types.enum [
            "light"
            "sensor"
            "switch"
            "button"
            "plug"
            "led_strip"
            "control"
          ];
          description = "Device type/category";
        };

        name = lib.mkOption {
          type = lib.types.str;
          default = "${config.room}.${config.type}";
          description = ''
            Device identifier. Defaults to "room.type" format.
            Override this when you have multiple devices of the same type in one room.
          '';
          example = "living_room.bulb_1";
        };

        metadata = lib.mkOption {
          type = lib.types.attrs;
          default = { };
          description = "Additional metadata (manufacturer, model, etc.)";
          example = {
            manufacturer = "IKEA";
            model = "LED1545G12";
          };
        };
      };
    }
  );

in
{
  options.devices = {
    zigbee = lib.mkOption {
      type = lib.types.listOf deviceType;
      default = [ ];
      description = ''
        Zigbee device registry for home automation.

        Devices defined here are automatically configured in:
        - Zigbee2MQTT (mqtt.nix)
        - Home Assistant (home-assistant/)
      '';
      example = lib.literalExpression ''
        [
          {
            ieee = "0x8c8b48fffef12834";
            room = "living_room";
            type = "light";
            # name defaults to "living_room.light"
          }
          {
            ieee = "0x8c8b48fffedd1d4f";
            room = "living_room";
            type = "light";
            name = "living_room.bulb_1"; # Override for multiple lights
          }
        ]
      '';
    };
  };

  config = {
    assertions =
      let
        ieees = map (d: d.ieee) cfg.zigbee;
        duplicateIeees = lib.filter (ieee: (lib.count (x: x == ieee) ieees) > 1) (lib.unique ieees);
        
        names = map (d: d.name) cfg.zigbee;
        duplicateNames = lib.filter (name: (lib.count (x: x == name) names) > 1) (lib.unique names);
      in
      [
        {
          assertion = duplicateIeees == [ ];
          message = "Duplicate IEEE addresses found in devices.zigbee: ${lib.concatStringsSep ", " duplicateIeees}";
        }
        {
          assertion = duplicateNames == [ ];
          message = "Duplicate device names found in devices.zigbee: ${lib.concatStringsSep ", " duplicateNames}. Override the 'name' field to make them unique.";
        }
      ];
  };
}
