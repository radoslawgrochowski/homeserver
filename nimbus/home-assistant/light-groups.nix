{ lib, ... }:
{
  light = [
    {
      platform = "group";
      name = "living-room/bulbs";
      entities = [
        "light.0x8c8b48fffef12834"
        "light.0x8c8b48fffedd1d4f"
        "light.0x94a081fffe706960"
      ];
    }
    {
      platform = "group";
      name = "kitchen/bulbs";
      entities = [
        "light.0x94a081fffe0f26f0"
        "light.0x8c8b48fffef12eac"
      ];
    }
    {
      platform = "group";
      name = "hall/bulbs";
      entities = [
        "light.0x8c8b48fffec49d39"
        "light.0x94a081fffeac2137"
      ];
    }
    {
      platform = "group";
      name = "all/bulbs";
      entities = [
        "light.0x8c8b48fffef12834"
        "light.0x8c8b48fffedd1d4f"
        "light.0x94a081fffe706960"
        "light.0x94a081fffe0f26f0"
        "light.0x8c8b48fffef12eac"
        "light.0x8c8b48fffec49d39"
        "light.0x94a081fffeac2137"
      ];
    }
  ];
}
