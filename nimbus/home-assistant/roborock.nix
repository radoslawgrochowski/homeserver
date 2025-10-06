{ lib }:
let
  vacuumEntity = "vacuum.roborock_s5_max";
  quietHoursStart = 22;
  quietHoursEnd = 8;

  slugify = name: builtins.replaceStrings [ "-" ] [ "_" ] name;
  uppercaseSlugify = name: slugify (lib.strings.toUpper name);

  rooms = {
    living-room = {
      id = 16;
      icon = "mdi:sofa";
      cleaningIntervalDays = 2;
    };
    kitchen = {
      id = 17;
      icon = "mdi:chef-hat";
      cleaningIntervalDays = 2;
    };
    hall = {
      id = 18;
      icon = "mdi:door";
      cleaningIntervalDays = 3;
    };
    office = {
      id = 19;
      icon = "mdi:desk";
      cleaningIntervalDays = 7;
    };
  };

  mkInputDatetime = name: {
    name = "${name} Last Cleaned";
    has_date = true;
    has_time = true;
  };

  mkScript = name: room: {
    alias = "Clean ${name}";
    icon = room.icon;
    sequence = [
      {
        service = "vacuum.send_command";
        target = {
          entity_id = vacuumEntity;
        };
        data = {
          command = "app_segment_clean";
          params = [ room.id ];
        };
      }
      {
        service = "input_datetime.set_datetime";
        target = {
          entity_id = "input_datetime.roborock_${slugify name}_last_cleaned";
        };
        data = {
          datetime = "{{ now().isoformat() }}";
        };
      }
    ];
  };

  mkSuggestionAutomation = name: room: {
    id = "roborock_suggest_${slugify name}_cleaning";
    alias = "Suggest ${name} Cleaning";
    description = "Suggest cleaning ${name} if not cleaned in ${toString room.cleaningIntervalDays} days";
    trigger = [
      {
        platform = "time";
        at = "09:00:00";
      }
    ];
    condition = [
      {
        condition = "template";
        value_template = "{{ (now().date() - (states('input_datetime.roborock_${slugify name}_last_cleaned') | as_datetime).date()).days >= ${toString room.cleaningIntervalDays} }}";
      }
      {
        condition = "template";
        value_template = "{{ now().hour >= ${toString quietHoursEnd} and now().hour < ${toString quietHoursStart} }}";
      }
      {
        condition = "state";
        entity_id = "binary_sensor.roborock_s5_max_cleaning";
        state = "off";
      }
    ];
    action = [
      {
        service = "notify.notify";
        data = {
          title = "🧹 ${name} Cleaning";
          message = "${name} hasn't been cleaned for ${toString room.cleaningIntervalDays}+ days. Last cleaned: {{ states('input_datetime.roborock_${slugify name}_last_cleaned') }}";
          data = {
            priority = "normal";
            tag = "room_cleaning_suggestion";
            actions = [
              {
                action = "CLEAN_${uppercaseSlugify name}";
                title = "Clean ${name}";
              }
            ];
          };
        };
      }
    ];
    mode = "single";
  };

  roomNames = builtins.attrNames rooms;

  inputDatetimes = builtins.listToAttrs (
    map (name: {
      name = "roborock_${slugify name}_last_cleaned";
      value = mkInputDatetime name;
    }) roomNames
  );

  scripts = builtins.listToAttrs (
    map (name: {
      name = "roborock_clean_${slugify name}";
      value = mkScript name rooms.${name};
    }) roomNames
  );

  suggestionAutomations = map (name: mkSuggestionAutomation name rooms.${name}) roomNames;

  actionHandlers = map (name: {
    platform = "event";
    event_type = "mobile_app_notification_action";
    event_data = {
      action = "CLEAN_${uppercaseSlugify name}";
    };
  }) roomNames;

  actionChoices = map (name: {
    conditions = [
      {
        condition = "template";
        value_template = "{{ trigger.event.data.action == 'CLEAN_${uppercaseSlugify name}' }}";
      }
    ];
    sequence = [
      {
        service = "script.roborock_clean_${slugify name}";
      }
    ];
  }) roomNames;

in
{
  input_datetime = inputDatetimes;
  script = scripts;
  automation = suggestionAutomations ++ [
    {
      id = "roborock_handle_notification_actions";
      alias = "Handle Room Cleaning Notification Actions";
      description = "Handle cleaning actions from notifications";
      trigger = actionHandlers;
      action = [ { choose = actionChoices; } ];
      mode = "queued";
    }
  ];
}
