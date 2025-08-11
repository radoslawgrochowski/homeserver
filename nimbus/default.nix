{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./users.nix
    ./networking.nix
    ./containers.nix
    ./dashy
    ./blocky
    ./restic.nix
    ./secrets.nix
    ./grafana.nix
    ./prometheus
    ./sensors.nix
    ./loki.nix
    ./promtail.nix
    ./nextcloud.nix
    ./postgresql.nix
    ./arr.nix
    ./jellyfin.nix
    ./home-assistant
    ./tailscale.nix
    ./mqtt.nix
    ./auto-upgrade.nix
    ./nix.nix
    ./zfs.nix
  ];


  time.timeZone = "Europe/Warsaw";
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  boot.loader.systemd-boot.enable = true;
  system.stateVersion = "24.05";
}
