{ ... }:
{
  imports = [
    ./tailscale.nix
    ./zfs.nix
    ./node-exporter.nix
    ./promtail.nix
    ./nix.nix
  ];
}
