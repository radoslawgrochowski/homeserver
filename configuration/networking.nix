{ ... }:
{
  networking = {
    hostName = "stratus";
    useDHCP = false;
    interfaces.eth0.useDHCP = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.0.8";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.0.1";
    nameservers = [ "8.8.8.8" "1.1.1.1" ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
}
