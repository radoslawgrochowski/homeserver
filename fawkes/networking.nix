{ config, ... }:
{
  networking = {
    useDHCP = false;
    interfaces.wlp2s0.useDHCP = true;
    interfaces.enp1s0.useDHCP = true;
    wireless = {
      enable = true;
      secretsFile = config.age.secrets.wifi-passwords.path;
      networks = {
        "NIEBIESKIE_NIEBO_5G" = {
          pskRaw = "ext:niebieskie_niebo";
          priority = 1;
        };
        "NIEBIESKIE_NIEBO" = {
          pskRaw = "ext:niebieskie_niebo";
        };
      };
    };
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
  };
}
