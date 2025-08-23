{ ... }: {
  services.sanoid = {
    enable = true;
    interval = "hourly";

    datasets."backup/nimbus-tank" = {
      recursive = true;
      hourly = 3;
      daily = 3;
      weekly = 3;
      monthly = 3;
      yearly = 3;
      autoprune = true;
      autosnap = false;
    };
  };
}

