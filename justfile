_default:
  just --list

update: 
  nix flake update

switch HOST *PARAMS:
  nixos-rebuild switch --flake . --target-host {{HOST}} --use-remote-sudo {{PARAMS}}

boot HOST *PARAMS:
  nixos-rebuild boot --flake . --target-host {{HOST}} --use-remote-sudo {{PARAMS}}
