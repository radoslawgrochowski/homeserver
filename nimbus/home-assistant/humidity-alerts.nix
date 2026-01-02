{ config, lib, ... }:

let
  defaultMin = 35;
  defaultMax = 55;

  humidityMonitoredSensors = lib.filter (d: d.type == "sensor") config.devices.zigbee;

  capitalize = str: "${lib.toUpper (builtins.substring 0 1 str)}${builtins.substring 1 (-1) str}";

  getMin = sensor: sensor.metadata.alerts.humidity.min or defaultMin;
  getMax = sensor: sensor.metadata.alerts.humidity.max or defaultMax;

  mkLowHumidityAlert =
    sensor:
    let
      threshold = getMin sensor;
      entityId = "sensor.${sensor.ieee}_humidity";
      roomName = capitalize sensor.room;
    in
    {
      id = "${sensor.room}_low_humidity_alert";
      alias = "${roomName} Low Humidity Alert";
      description = "Alert when ${sensor.room} humidity drops below ${toString threshold}%";
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
            {% set last_triggered = state_attr('automation.${sensor.room}_low_humidity_alert', 'last_triggered') %}
            {{ last_triggered == none or (now() - last_triggered).total_seconds() > 86400 }}
          '';
        }
      ];
      action = [
        {
          service = "notify.notify";
          data = {
            title = "💧 Low Humidity Alert";
            message = "${roomName} humidity is {{ trigger.to_state.state }}% (below ${toString threshold}% threshold)";
            data = {
              priority = "normal";
              tag = "${sensor.room}_humidity_low";
            };
          };
        }
        {
          service = "logbook.log";
          data = {
            name = "Humidity Alert";
            message = "${roomName} humidity dropped below ${toString threshold}%: {{ trigger.to_state.state }}%";
          };
        }
      ];
      mode = "single";
    };

  mkHighHumidityAlert =
    sensor:
    let
      threshold = getMax sensor;
      entityId = "sensor.${sensor.ieee}_humidity";
      roomName = capitalize sensor.room;
    in
    {
      id = "${sensor.room}_high_humidity_alert";
      alias = "${roomName} High Humidity Alert";
      description = "Alert when ${sensor.room} humidity exceeds ${toString threshold}%";
      trigger = [
        {
          platform = "numeric_state";
          entity_id = entityId;
          above = threshold;
          for.minutes = 15;
        }
      ];
      condition = [
        {
          condition = "template";
          value_template = ''
            {% set last_triggered = state_attr('automation.${sensor.room}_high_humidity_alert', 'last_triggered') %}
            {{ last_triggered == none or (now() - last_triggered).total_seconds() > 86400 }}
          '';
        }
      ];
      action = [
        {
          service = "notify.notify";
          data = {
            title = "💧 High Humidity Alert";
            message = "${roomName} humidity is {{ trigger.to_state.state }}% (above ${toString threshold}% threshold)";
            data = {
              priority = "normal";
              tag = "${sensor.room}_humidity_high";
            };
          };
        }
        {
          service = "logbook.log";
          data = {
            name = "Humidity Alert";
            message = "${roomName} humidity exceeded ${toString threshold}%: {{ trigger.to_state.state }}%";
          };
        }
      ];
      mode = "single";
    };

in
lib.flatten [
  (map mkLowHumidityAlert humidityMonitoredSensors)
  (map mkHighHumidityAlert humidityMonitoredSensors)
]
