export NIX_SSHOPTS := "-t"

_default:
  just --list

update: 
  nix flake update

switch *PARAMS: 
  nixos-rebuild switch --flake .#stratus --target-host stratus@stratus.local --use-remote-sudo {{PARAMS}}

