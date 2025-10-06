[
  {
    id = "living_room_high_temperature_alert";
    alias = "Living Room High Temperature Alert";
    description = "Alert when living room temperature exceeds 28°C and AC is off";
    trigger = [
      {
        platform = "numeric_state";
        entity_id = "sensor.living_room_sensor_temperature";
        above = 28;
        for = {
          hours = 0;
          minutes = 15;
          seconds = 0;
        };
      }
    ];
    condition = [
      {
        condition = "state";
        entity_id = "climate.gree_climate_gree_c03937a1ae5c";
        state = "off";
      }
    ];
    action = [
      {
        service = "notify.notify";
        data = {
          title = "🌡️ High Temperature Alert";
          message = "Living room temperature is {{ states('sensor.living_room_sensor_temperature') }}°C (above 28°C threshold) and AC is off";
          data = {
            priority = "high";
            tag = "temperature_alert";
            actions = [
              {
                action = "TURN_ON_AC";
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
          message = "Living room temperature exceeded 28°C: {{ states('sensor.living_room_sensor_temperature') }}°C";
        };
      }
    ];
    mode = "single";
  }
  {
    id = "turn_on_ac_from_notification";
    alias = "Turn On AC from Notification";
    description = "Turn on AC when notification action is pressed";
    trigger = [
      {
        platform = "event";
        event_type = "mobile_app_notification_action";
        event_data = {
          action = "TURN_ON_AC";
        };
      }
    ];
    condition = [ ];
    action = [
      {
        service = "climate.turn_on";
        target = {
          entity_id = "climate.gree_climate_gree_c03937a1ae5c";
        };
      }
      {
        service = "climate.set_hvac_mode";
        target = {
          entity_id = "climate.gree_climate_gree_c03937a1ae5c";
        };
        data = {
          hvac_mode = "cool";
        };
      }
      {
        service = "notify.notify";
        data = {
          title = "❄️ AC Turned On";
          message = "Living room AC has been turned on.";
        };
      }
    ];
    mode = "single";
  }
]
