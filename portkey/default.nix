{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./users.nix
    ./fail2ban.nix
    ./pangolin
  ];

  networking.hostName = "portkey";

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };
  networking.useDHCP = false;
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "154.46.30.187";
      prefixLength = 25;
    }
  ];
  networking.defaultGateway = "154.46.30.129";
  networking.nameservers = [
    "8.8.8.8"
    "1.1.1.1"
  ];

  system.stateVersion = "25.05";
}
