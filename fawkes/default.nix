{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./users.nix
    ./secrets.nix
    ./sanoid.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "fawkes";

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "yes";

  system.stateVersion = "25.05";
}
