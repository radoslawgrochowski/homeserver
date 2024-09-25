export NIX_SSHOPTS := "-t"

_default:
  just --list

update: 
  nix flake update

switch *PARAMS: 
  nixos-rebuild switch --flake .#stratus --target-host stratus@192.168.0.8 --use-remote-sudo {{PARAMS}}

