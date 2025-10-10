{ lib }:

let
  mkLightSwitchCombo =
    {
      name,
      bulb,
      switch,
    }:
    {
      script."turn_on_${name}" = {
        sequence = [
          {
            condition = "template";
            value_template = "{{ is_state('${switch}', 'off') }}";
          }
          {
            service = "switch.turn_on";
            target.entity_id = switch;
          }
          {
            delay.seconds = 1;
          }
        ];
      };
      automation = [
        {
          alias = "${name}: Ensure power before turn on";
          trigger = {
            platform = "event";
            event_type = "call_service";
            event_data = {
              domain = "light";
              service = "turn_on";
            };
          };
          condition = {
            condition = "template";
            value_template = "{{ trigger.event.data.service_data.entity_id == '${bulb}' or '${bulb}' in trigger.event.data.service_data.get('entity_id', []) }}";
          };
          action = {
            service = "script.turn_on_${name}";
          };
        }
        {
          alias = "${name}: Sync bulb state when switch turns off";
          trigger = {
            platform = "state";
            entity_id = switch;
            to = "off";
          };
          action = {
            service = "light.turn_off";
            target.entity_id = bulb;
          };
        }
      ];
    };

  lightSwitchCombos = [
    {
      name = "bedroom_light";
      bulb = "light.0xd44867fffe150cc2";
      switch = "switch.bedroom_switch";
    }
  ];

  combos = map mkLightSwitchCombo lightSwitchCombos;
in
{
  script = lib.mergeAttrsList (map (c: c.script) combos);
  automation = lib.flatten (map (c: c.automation) combos);
}
