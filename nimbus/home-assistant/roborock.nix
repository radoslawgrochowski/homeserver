{
  input_datetime = {
    roborock_living_room_last_cleaned = {
      name = "Living Room Last Cleaned";
      has_date = true;
      has_time = true;
    };
    roborock_kitchen_last_cleaned = {
      name = "Kitchen Last Cleaned";
      has_date = true;
      has_time = true;
    };
    roborock_hall_last_cleaned = {
      name = "Hall Last Cleaned";
      has_date = true;
      has_time = true;
    };
    roborock_office_last_cleaned = {
      name = "Office Last Cleaned";
      has_date = true;
      has_time = true;
    };
  };

  script = {
    roborock_clean_living_room = {
      alias = "Clean Living Room";
      icon = "mdi:sofa";
      sequence = [
        {
          service = "vacuum.send_command";
          target = {
            entity_id = "vacuum.roborock_s5_max";
          };
          data = {
            command = "app_segment_clean";
            params = [ 16 ];
          };
        }
        {
          service = "input_datetime.set_datetime";
          target = {
            entity_id = "input_datetime.roborock_living_room_last_cleaned";
          };
          data = {
            datetime = "{{ now().isoformat() }}";
          };
        }
      ];
    };
    roborock_clean_kitchen = {
      alias = "Clean Kitchen";
      icon = "mdi:chef-hat";
      sequence = [
        {
          service = "vacuum.send_command";
          target = {
            entity_id = "vacuum.roborock_s5_max";
          };
          data = {
            command = "app_segment_clean";
            params = [ 18 ];
          };
        }
        {
          service = "input_datetime.set_datetime";
          target = {
            entity_id = "input_datetime.roborock_kitchen_last_cleaned";
          };
          data = {
            datetime = "{{ now().isoformat() }}";
          };
        }
      ];
    };
    roborock_clean_hall = {
      alias = "Clean Hall";
      icon = "mdi:door";
      sequence = [
        {
          service = "vacuum.send_command";
          target = {
            entity_id = "vacuum.roborock_s5_max";
          };
          data = {
            command = "app_segment_clean";
            params = [ 17 ];
          };
        }
        {
          service = "input_datetime.set_datetime";
          target = {
            entity_id = "input_datetime.roborock_hall_last_cleaned";
          };
          data = {
            datetime = "{{ now().isoformat() }}";
          };
        }
      ];
    };
    roborock_clean_office = {
      alias = "Clean Office";
      icon = "mdi:desk";
      sequence = [
        {
          service = "vacuum.send_command";
          target = {
            entity_id = "vacuum.roborock_s5_max";
          };
          data = {
            command = "app_segment_clean";
            params = [ 19 ];
          };
        }
        {
          service = "input_datetime.set_datetime";
          target = {
            entity_id = "input_datetime.roborock_office_last_cleaned";
          };
          data = {
            datetime = "{{ now().isoformat() }}";
          };
        }
      ];
    };
  };
}

