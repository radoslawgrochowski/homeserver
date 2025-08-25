{ ... }:
{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";

    jails = {
      sshd = {
        settings = {
          enabled = true;
          port = "ssh";
          logpath = "/var/log/auth.log";
          maxretry = 3;
          bantime = "3h";
          findtime = "10m";
        };
      };

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

