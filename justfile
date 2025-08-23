_default:
  just --list

update: 
  nix flake update

check HOST:
  nixos-rebuild dry-activate --flake . --target-host {{HOST}}

switch HOST *PARAMS:
  nixos-rebuild switch --flake . --target-host {{HOST}} --use-remote-sudo {{PARAMS}}

boot HOST *PARAMS:
  nixos-rebuild boot --flake . --target-host {{HOST}} --use-remote-sudo {{PARAMS}}

