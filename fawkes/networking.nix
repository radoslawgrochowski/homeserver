{ config, ... }:
{
  networking = {
    useDHCP = false;
    interfaces.wlp2s0.useDHCP = true;
    interfaces.enp1s0.useDHCP = true;

    wireless = {
      enable = true;
      secretsFile = config.age.secrets.wifi-passwords.path;
      interfaces = [ "wlp2s0" ];
      networks = {
        Grochowscy_5G = {
          pskRaw = "ext:grochowscy";
          priority = 1;
        };
        Grochowscy = {
          pskRaw = "ext:grochowscy";
        };
      };
    };
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
  };
}
