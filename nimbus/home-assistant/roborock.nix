{ lib }:
let
  vacuumEntity = "vacuum.roborock_s5_max";
  cancelledBoolean = "input_boolean.roborock_cleaning_cancelled";
  cleanedRoomsText = "input_text.roborock_cleaned_rooms";

  slugify = name: builtins.replaceStrings [ "-" ] [ "_" ] name;
  uppercaseSlugify = name: slugify (lib.strings.toUpper name);

  rooms = {
    living-room = {
      id = 16;
      icon = "mdi:sofa";
      cleaningIntervalDays = 2;
    };
    kitchen = {
      id = 18;
      icon = "mdi:chef-hat";
      cleaningIntervalDays = 2;
    };
    hall = {
      id = 17;
      icon = "mdi:door";
      cleaningIntervalDays = 2;
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
        service = "notify.notify";
        data = {
          title = "🧹 Cleaning in Progress";
          message = "Cleaning ${name}...";
          data = {
            tag = "roborock_cleaning";
            priority = "high";
            actions = [
              {
                action = "CANCEL_CLEANING";
                title = "Cancel";
              }
            ];
          };
        };
      }
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
      {
        wait_for_trigger = [
          {
            platform = "state";
            entity_id = vacuumEntity;
            from = "cleaning";
          }
        ];
        timeout = "00:30:00";
      }
      {
        choose = [
          {
            conditions = [
              {
                condition = "state";
                entity_id = cancelledBoolean;
                state = "on";
              }
            ];
            sequence = [
              {
                service = "input_boolean.turn_off";
                target = {
                  entity_id = cancelledBoolean;
                };
              }
            ];
          }
          {
            conditions = [
              {
                condition = "state";
                entity_id = cancelledBoolean;
                state = "off";
              }
            ];
            sequence = [
              {
                service = "notify.notify";
                data = {
                  title = "✅ Cleaning Complete";
                  message = "${name} has been cleaned!";
                  data = {
                    tag = "roborock_cleaning";
                    priority = "normal";
                  };
                };
              }
            ];
          }
        ];
      }
    ];
  };

  roomNames = builtins.attrNames rooms;

  inputDatetimes = builtins.listToAttrs (
    map (name: {
      name = "roborock_${slugify name}_last_cleaned";
      value = mkInputDatetime name;
    }) roomNames
  );

  scripts =
    builtins.listToAttrs (
      map (name: {
        name = "roborock_clean_${slugify name}";
        value = mkScript name rooms.${name};
      }) roomNames
    )
    // {
      roborock_clean_overdue_rooms = {
        alias = "Clean Overdue Rooms";
        icon = "mdi:robot-vacuum";
        sequence = [
          {
            service = "notify.notify";
            data = {
              title = "🧹 Cleaning in Progress";
              message = ''
                {%- set ns = namespace(overdue_rooms=[]) %}
                {%- for room_name, room_data in {
                  "living-room": {"interval": ${toString rooms.living-room.cleaningIntervalDays}},
                  "kitchen": {"interval": ${toString rooms.kitchen.cleaningIntervalDays}},
                  "hall": {"interval": ${toString rooms.hall.cleaningIntervalDays}},
                  "office": {"interval": ${toString rooms.office.cleaningIntervalDays}}
                }.items() %}
                  {%- set room_slug = room_name | replace("-", "_") %}
                  {%- set last_cleaned = states('input_datetime.roborock_' + room_slug + '_last_cleaned') | as_datetime %}
                  {%- if last_cleaned and (now().date() - last_cleaned.date()).days >= room_data.interval %}
                    {%- set ns.overdue_rooms = ns.overdue_rooms + [room_name] %}
                  {%- endif %}
                {%- endfor %}
                Cleaning overdue rooms: {{ ns.overdue_rooms | join(', ') }}...
              '';
              data = {
                tag = "roborock_cleaning";
                priority = "high";
                actions = [
                  {
                    action = "CANCEL_CLEANING";
                    title = "Cancel";
                  }
                ];
              };
            };
          }
          {
            service = "input_text.set_value";
            target = {
              entity_id = cleanedRoomsText;
            };
            data = {
              value = ''
                {%- set ns = namespace(overdue_rooms=[]) %}
                {%- for room_name, room_data in {
                  "living-room": {"interval": ${toString rooms.living-room.cleaningIntervalDays}},
                  "kitchen": {"interval": ${toString rooms.kitchen.cleaningIntervalDays}},
                  "hall": {"interval": ${toString rooms.hall.cleaningIntervalDays}},
                  "office": {"interval": ${toString rooms.office.cleaningIntervalDays}}
                }.items() %}
                  {%- set room_slug = room_name | replace("-", "_") %}
                  {%- set last_cleaned = states('input_datetime.roborock_' + room_slug + '_last_cleaned') | as_datetime %}
                  {%- if last_cleaned and (now().date() - last_cleaned.date()).days >= room_data.interval %}
                    {%- set ns.overdue_rooms = ns.overdue_rooms + [room_name] %}
                  {%- endif %}
                {%- endfor %}
                {{ ns.overdue_rooms | join(', ') }}
              '';
            };
          }
          {
            service = "vacuum.send_command";
            target = {
              entity_id = vacuumEntity;
            };
            data = {
              command = "app_segment_clean";
              params = ''
                {%- set ns = namespace(overdue_room_ids=[]) %}
                {%- for room_name, room_data in {
                  "living-room": {"interval": ${toString rooms.living-room.cleaningIntervalDays}, "id": ${toString rooms.living-room.id}},
                  "kitchen": {"interval": ${toString rooms.kitchen.cleaningIntervalDays}, "id": ${toString rooms.kitchen.id}},
                  "hall": {"interval": ${toString rooms.hall.cleaningIntervalDays}, "id": ${toString rooms.hall.id}},
                  "office": {"interval": ${toString rooms.office.cleaningIntervalDays}, "id": ${toString rooms.office.id}}
                }.items() %}
                  {%- set room_slug = room_name | replace("-", "_") %}
                  {%- set last_cleaned = states('input_datetime.roborock_' + room_slug + '_last_cleaned') | as_datetime %}
                  {%- if last_cleaned and (now().date() - last_cleaned.date()).days >= room_data.interval %}
                    {%- set ns.overdue_room_ids = ns.overdue_room_ids + [room_data.id] %}
                  {%- endif %}
                {%- endfor %}
                {{ ns.overdue_room_ids }}
              '';
            };
          }
          {
            repeat = {
              for_each = ''
                {%- set ns = namespace(overdue_rooms=[]) %}
                {%- for room_name, room_data in {
                  "living-room": {"interval": ${toString rooms.living-room.cleaningIntervalDays}},
                  "kitchen": {"interval": ${toString rooms.kitchen.cleaningIntervalDays}},
                  "hall": {"interval": ${toString rooms.hall.cleaningIntervalDays}},
                  "office": {"interval": ${toString rooms.office.cleaningIntervalDays}}
                }.items() %}
                  {%- set room_slug = room_name | replace("-", "_") %}
                  {%- set last_cleaned = states('input_datetime.roborock_' + room_slug + '_last_cleaned') | as_datetime %}
                  {%- if last_cleaned and (now().date() - last_cleaned.date()).days >= room_data.interval %}
                    {%- set ns.overdue_rooms = ns.overdue_rooms + [room_name] %}
                  {%- endif %}
                {%- endfor %}
                {{ ns.overdue_rooms }}
              '';
              sequence = [
                {
                  service = "input_datetime.set_datetime";
                  target = {
                    entity_id = "input_datetime.roborock_{{ repeat.item | replace('-', '_') }}_last_cleaned";
                  };
                  data = {
                    datetime = "{{ now().isoformat() }}";
                  };
                }
              ];
            };
          }
          {
            wait_for_trigger = [
              {
                platform = "state";
                entity_id = vacuumEntity;
                from = "cleaning";
              }
            ];
            timeout = "00:30:00";
          }
          {
            choose = [
              {
                conditions = [
                  {
                    condition = "state";
                    entity_id = cancelledBoolean;
                    state = "on";
                  }
                ];
                sequence = [
                  {
                    service = "input_boolean.turn_off";
                    target = {
                      entity_id = cancelledBoolean;
                    };
                  }
                ];
              }
              {
                conditions = [
                  {
                    condition = "state";
                    entity_id = cancelledBoolean;
                    state = "off";
                  }
                ];
                sequence = [
                  {
                    service = "notify.notify";
                    data = {
                      title = "✅ Cleaning Complete";
                      message = "Cleaned: {{ states('${cleanedRoomsText}') }}";
                      data = {
                        tag = "roborock_cleaning";
                        priority = "normal";
                      };
                    };
                  }
                ];
              }
            ];
          }
        ];
      };
    };

  overdueCleaningAutomation = {
    id = "roborock_auto_clean_overdue";
    alias = "Auto Clean Overdue Rooms";
    description = "Automatically clean rooms that are overdue for cleaning";
    trigger = [
      {
        platform = "time";
        at = "07:45:00";
      }
    ];
    condition = [
      {
        condition = "template";
        value_template = ''
          {%- set ns = namespace(overdue_rooms=[]) %}
          {%- for room_name, room_data in {
            "living-room": {"interval": ${toString rooms.living-room.cleaningIntervalDays}},
            "kitchen": {"interval": ${toString rooms.kitchen.cleaningIntervalDays}},
            "hall": {"interval": ${toString rooms.hall.cleaningIntervalDays}},
            "office": {"interval": ${toString rooms.office.cleaningIntervalDays}}
          }.items() %}
            {%- set room_slug = room_name | replace("-", "_") %}
            {%- set last_cleaned = states('input_datetime.roborock_' + room_slug + '_last_cleaned') | as_datetime %}
            {%- if last_cleaned and (now().date() - last_cleaned.date()).days >= room_data.interval %}
              {%- set ns.overdue_rooms = ns.overdue_rooms + [room_name] %}
            {%- endif %}
          {%- endfor %}
          {{ ns.overdue_rooms | length > 0 }}
        '';
      }
      {
        condition = "state";
        entity_id = "binary_sensor.roborock_s5_max_cleaning";
        state = "off";
      }
    ];
    action = [
      {
        service = "script.roborock_clean_overdue_rooms";
      }
    ];
    mode = "single";
  };

  actionHandlers =
    map (name: {
      platform = "event";
      event_type = "mobile_app_notification_action";
      event_data = {
        action = "CLEAN_${uppercaseSlugify name}";
      };
    }) roomNames
    ++ [
      {
        platform = "event";
        event_type = "mobile_app_notification_action";
        event_data = {
          action = "CLEAN_OVERDUE";
        };
      }
      {
        platform = "event";
        event_type = "mobile_app_notification_action";
        event_data = {
          action = "CANCEL_CLEANING";
        };
      }
    ];

  actionChoices =
    map (name: {
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
    }) roomNames
    ++ [
      {
        conditions = [
          {
            condition = "template";
            value_template = "{{ trigger.event.data.action == 'CLEAN_OVERDUE' }}";
          }
        ];
        sequence = [
          {
            service = "script.roborock_clean_overdue_rooms";
          }
        ];
      }
      {
        conditions = [
          {
            condition = "template";
            value_template = "{{ trigger.event.data.action == 'CANCEL_CLEANING' }}";
          }
        ];
        sequence = [
          {
            service = "input_boolean.turn_on";
            target = {
              entity_id = cancelledBoolean;
            };
          }
          {
            service = "notify.notify";
            data = {
              title = "❌ Cleaning Cancelled";
              message = "Returning vacuum to dock...";
              data = {
                tag = "roborock_cleaning";
                priority = "normal";
              };
            };
          }
          {
            service = "vacuum.return_to_base";
            target = {
              entity_id = vacuumEntity;
            };
          }
        ];
      }
    ];

in
{
  input_datetime = inputDatetimes;
  input_boolean = {
    roborock_cleaning_cancelled = {
      name = "Roborock Cleaning Cancelled";
      initial = false;
    };
  };
  input_text = {
    roborock_cleaned_rooms = {
      name = "Roborock Cleaned Rooms";
    };
  };
  script = scripts;
  automation = [
    overdueCleaningAutomation
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
