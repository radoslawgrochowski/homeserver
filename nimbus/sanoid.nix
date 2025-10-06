{ ... }:
{
  services.sanoid = {
    enable = true;
    interval = "hourly";

    datasets."tank" = {
      recursive = true;
      hourly = 24;
      daily = 3;
      weekly = 3;
      monthly = 3;
      yearly = 3;
      autoprune = true;
      autosnap = true;
    };
  };

  services.syncoid = {
    enable = true;
    interval = "*-*-* 03:14:00";

    commands."tank" = {
      source = "tank";
      target = "fawkes@fawkes:backup/nimbus-tank";
      recursive = true;
      extraArgs = [
        "--no-sync-snap"
        "--sshkey"
        "/etc/ssh/syncoid_fawkes_key"
      ];
    };
  };
}
