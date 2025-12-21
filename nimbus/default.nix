{ pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./users.nix
    ./networking.nix
    ./containers.nix
    ./dashy
    ./blocky
    ./restic.nix
    ./secrets.nix
    ./grafana
    ./prometheus
    ./sensors.nix
    ./loki.nix
    ./nextcloud.nix
    ./postgresql.nix
    ./arr.nix
    ./jellyfin.nix
    ./home-assistant
    ./mqtt.nix
    ./auto-upgrade.nix
    ./sanoid.nix
    ./security.nix
    ./ddns.nix
    ./acme.nix
    ./collabora.nix
    ./palworld.nix
  ];

  time.timeZone = "Europe/Warsaw";
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
  programs.ssh.knownHosts = {
    fawkes = {
      hostNames = [ "fawkes" ];
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICi5oQZI2Py3n5KNZqB7v26A3z3leFop6TVMvnugQJGN";
    };
  };
  boot.loader.systemd-boot.enable = true;
  system.stateVersion = "24.05";
}
