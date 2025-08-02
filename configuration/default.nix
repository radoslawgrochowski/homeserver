{ pkgs, ... }:

{
  imports = [
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
    ./home-assistant.nix
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
}

