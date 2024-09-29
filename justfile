export NIX_SSHOPTS := "-t"

_default:
  just --list

update: 
  nix flake update

switch *PARAMS: 
  nixos-rebuild switch --flake .#nimbus --target-host nimbus@nimbus.local --use-remote-sudo {{PARAMS}}

boot *PARAMS: 
  nixos-rebuild boot --flake .#nimbus --target-host nimbus@nimbus.local --use-remote-sudo {{PARAMS}}

