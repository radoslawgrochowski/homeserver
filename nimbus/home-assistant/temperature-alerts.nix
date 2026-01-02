{ config, lib, ... }:

let
  defaultTempMin = 18;
  defaultTempMax = 26;

  temperatureMonitoredSensors = lib.filter (d: d.type == "sensor") config.devices.zigbee;

  capitalize = str: "${lib.toUpper (builtins.substring 0 1 str)}${builtins.substring 1 (-1) str}";

  getTempMin = sensor: sensor.metadata.alerts.temperature.min or defaultTempMin;
  getTempMax = sensor: sensor.metadata.alerts.temperature.max or defaultTempMax;
  getAcEntity = sensor: sensor.metadata.alerts.temperature.ac_entity or null;

  mkLowTempAlert =
    sensor:
    let
      threshold = getTempMin sensor;
      entityId = "sensor.${sensor.ieee}_temperature";
      roomName = capitalize sensor.room;
    in
    lib.optional (sensor.metadata.alerts.temperature.min or null != null) {
      id = "${sensor.room}_low_temperature_alert";
      alias = "${roomName} Low Temperature Alert";
      description = "Alert when ${sensor.room} temperature drops below ${toString threshold}°C";
      trigger = [
        {
          platform = "numeric_state";
          entity_id = entityId;
          below = threshold;
          for.minutes = 15;
        }
      ];
      condition = [
        {
          condition = "template";
          value_template = ''
            {% set last_triggered = state_attr('automation.${sensor.room}_low_temperature_alert', 'last_triggered') %}
            {{ last_triggered == none or (now() - last_triggered).total_seconds() > 86400 }}
          '';
        }
      ];
      action = [
        {
          service = "notify.notify";
          data = {
            title = "🌡️ Low Temperature Alert";
            message = "${roomName} temperature is {{ trigger.to_state.state }}°C (below ${toString threshold}°C threshold)";
            data = {
              priority = "normal";
              tag = "${sensor.room}_temperature_low";
            };
          };
        }
        {
          service = "logbook.log";
          data = {
            name = "Temperature Alert";
            message = "${roomName} temperature dropped below ${toString threshold}°C: {{ trigger.to_state.state }}°C";
          };
        }
      ];
      mode = "single";
    };

  mkHighTempAlert =
    sensor:
    let
      threshold = getTempMax sensor;
      entityId = "sensor.${sensor.ieee}_temperature";
      roomName = capitalize sensor.room;
      acEntity = getAcEntity sensor;
      hasAc = acEntity != null;
    in
    {
      id = "${sensor.room}_high_temperature_alert";
      alias = "${roomName} High Temperature Alert";
      description = "Alert when ${sensor.room} temperature exceeds ${toString threshold}°C" + (if hasAc then " and AC is off" else "");
      trigger = [
        {
          platform = "numeric_state";
          entity_id = entityId;
          above = threshold;
          for.minutes = 15;
        }
      ];
      condition =
        [
          {
            condition = "template";
            value_template = ''
              {% set last_triggered = state_attr('automation.${sensor.room}_high_temperature_alert', 'last_triggered') %}
              {{ last_triggered == none or (now() - last_triggered).total_seconds() > 86400 }}
            '';
          }
        ]
        ++ lib.optional hasAc {
          condition = "state";
          entity_id = acEntity;
          state = "off";
        };
      action = [
        {
          service = "notify.notify";
          data = {
            title = "🌡️ High Temperature Alert";
            message =
              "${roomName} temperature is {{ trigger.to_state.state }}°C (above ${toString threshold}°C threshold)"
              + (if hasAc then " and AC is off" else "");
            data =
              {
                priority = "high";
                tag = "${sensor.room}_temperature_high";
              }
              // lib.optionalAttrs hasAc {
                actions = [
                  {
                    action = "TURN_ON_AC_${lib.toUpper sensor.room}";
                    title = "Turn On AC";
                  }
                ];
              };
          };
        }
        {
          service = "logbook.log";
          data = {
            name = "Temperature Alert";
            message = "${roomName} temperature exceeded ${toString threshold}°C: {{ trigger.to_state.state }}°C";
          };
        }
      ];
      mode = "single";
    };

  mkAcTurnOnHandler =
    sensor:
    let
      acEntity = getAcEntity sensor;
      roomName = capitalize sensor.room;
    in
    lib.optional (acEntity != null) {
      id = "${sensor.room}_turn_on_ac_from_notification";
      alias = "${roomName} Turn On AC from Notification";
      description = "Turn on ${sensor.room} AC when notification action is pressed";
      trigger = [
        {
          platform = "event";
          event_type = "mobile_app_notification_action";
          event_data = {
            action = "TURN_ON_AC_${lib.toUpper sensor.room}";
          };
        }
      ];
      condition = [ ];
      action = [
        {
          service = "climate.turn_on";
          target.entity_id = acEntity;
        }
        {
          service = "climate.set_hvac_mode";
          target.entity_id = acEntity;
          data.hvac_mode = "cool";
        }
        {
          service = "notify.notify";
          data = {
            title = "❄️ AC Turned On";
            message = "${roomName} AC has been turned on.";
          };
        }
      ];
      mode = "single";
    };

in
lib.flatten [
  (lib.flatten (map mkLowTempAlert temperatureMonitoredSensors))
  (map mkHighTempAlert temperatureMonitoredSensors)
  (lib.flatten (map mkAcTurnOnHandler temperatureMonitoredSensors))
]
