{ ... }:
{
  networking = {
    hostName = "nimbus";
    useDHCP = false;
    interfaces.eth0.useDHCP = false;
    interfaces.eth0.ipv4.addresses = [{
      address = "192.168.0.8";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.0.1";

    interfaces.eth0.ipv6.addresses = [{
      address = "fd0e:fdc6:840e::8";
      prefixLength = 60;
    }];
    defaultGateway6 = {
      address = "fd0e:fdc6:840e::1";
      interface = "eth0";
    };

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

  services.nginx = {
    enable = true;
    virtualHosts = {
      "_" = {
        default = true;
        extraConfig = ''
          return 444;  # Close connection without response
        '';
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
