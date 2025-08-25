{ ... }:
{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";

    jails = {
      nginx-http-auth = {
        settings = {
          enabled = true;
          port = "80,443";
          logpath = "/var/log/nginx/access.log";
          maxretry = 5;
          bantime = "30m";
          findtime = "10m";
        };
      };
    };
  };
}

