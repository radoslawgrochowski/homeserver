{ ... }:
{
  imports = [
    ./tailscale.nix
    ./zfs.nix
    ./node-exporter.nix
  ];
}
