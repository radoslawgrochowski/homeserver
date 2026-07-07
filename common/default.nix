{ ... }:
{
  imports = [
    ./tailscale.nix
    ./zfs.nix
    ./node-exporter.nix
    ./alloy.nix
    ./nix.nix
  ];
}
