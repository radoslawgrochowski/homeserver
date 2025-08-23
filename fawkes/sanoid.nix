{ ... }: {
  services.sanoid = {
    enable = true;
    interval = "hourly";

    datasets."backup/nimbus-tank" = {
      recursive = true;
      hourly = 48;
      daily = 14;
      weekly = 8;
      monthly = 24;
      yearly = 5;
      autoprune = true;
      autosnap = false;
    };
  };
}

