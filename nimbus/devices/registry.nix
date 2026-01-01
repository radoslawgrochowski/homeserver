{ ... }:

{
  devices.zigbee = [
    # Bedroom
    {
      ieee = "0x44e2f8fffe21cb74";
      room = "bedroom";
      type = "button";
    }
    {
      ieee = "0xa4c138af4f0aef38";
      room = "bedroom";
      type = "switch";
    }
    {
      ieee = "0x94ec32fffeff21f7";
      room = "bedroom";
      type = "plug";
    }
    {
      ieee = "0xd44867fffe150cc2";
      room = "bedroom";
      type = "light";
    }
    {
      ieee = "0x08b95ffffed9f8b5";
      room = "bedroom";
      type = "control";
    }
    {
      ieee = "0x44e2f8fffe0149d0";
      room = "bedroom";
      type = "led_strip";
    }

    # Living Room
    {
      ieee = "0x08ddebfffef1a9f8";
      room = "living_room";
      type = "sensor";
    }
    {
      ieee = "0x0c2a6ffffe22d8e5";
      room = "living_room";
      type = "light";
      name = "living_room.floor_lamp";
    }
    {
      ieee = "0x8c8b48fffef12834";
      room = "living_room";
      type = "light";
      name = "living_room.bulb_1";
    }
    {
      ieee = "0x8c8b48fffedd1d4f";
      room = "living_room";
      type = "light";
      name = "living_room.bulb_2";
    }
    {
      ieee = "0x94a081fffe706960";
      room = "living_room";
      type = "light";
      name = "living_room.bulb_3";
    }
    {
      ieee = "0x781c9dfffe29414e";
      room = "living_room";
      type = "led_strip";
    }

    # Kitchen
    {
      ieee = "0x94a081fffe0f26f0";
      room = "kitchen";
      type = "light";
      name = "kitchen.bulb_1";
    }
    {
      ieee = "0x8c8b48fffef12eac";
      room = "kitchen";
      type = "light";
      name = "kitchen.bulb_2";
    }

    # Hall
    {
      ieee = "0x8c8b48fffec49d39";
      room = "hall";
      type = "light";
      name = "hall.bulb_1";
    }
    {
      ieee = "0x94a081fffeac2137";
      room = "hall";
      type = "light";
      name = "hall.bulb_2";
    }

    # Loggia
    {
      ieee = "0x0ceff6fffe675963";
      room = "loggia";
      type = "sensor";
    }

    # Office
    {
      ieee = "0x842712fffe380961";
      room = "office";
      type = "sensor";
    }
  ];
}
