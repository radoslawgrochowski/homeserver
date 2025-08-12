export NIX_SSHOPTS := "-t"

_default:
  just --list

update: 
  nix flake update

switch HOST *PARAMS:
  nixos-rebuild switch --flake .#{{HOST}} --target-host {{HOST}}@{{HOST}} --use-remote-sudo {{PARAMS}}

boot HOST *PARAMS:
  nixos-rebuild boot --flake .#{{HOST}} --target-host {{HOST}}@{{HOST}} --use-remote-sudo {{PARAMS}}
