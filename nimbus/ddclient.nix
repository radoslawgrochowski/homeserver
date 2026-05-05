{ config, ... }:
{
  services.ddclient = {
    enable = true;
    protocol = "ovh";
    server = "dns.eu.ovhapis.com";
    passwordFile = config.age.secrets.ddclient-password.path;
    domains = [ "nimbus.fard.pl" ];
    usev6 = "";
    interval = "1min";
    verbose = true;
  };
}
