{ ... }:
{
  system.autoUpgrade = {
    enable = true;
    flake = "github:radoslawgrochowski/homeserver";
    dates = "04:40";
  };
}
