{ ... }:
{
  system.autoUpgrade = {
    enable = false;
    allowReboot = true;
    flake = "github:radoslawgrochowski/homeserver";
    dates = "04:10";
    rebootWindow = {
      lower = "04:00";
      upper = "05:00";
    };
  };
}
