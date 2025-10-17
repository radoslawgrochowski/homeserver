{ ... }:
{
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "4h";
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32";
    };
  };
}
