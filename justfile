_default:
  just --list

check: 
  nix flake check 

update: 
  nix flake update

format:
  nix fmt ./**/*.nix

dry-activate HOST:
  nixos-rebuild dry-activate --flake . --target-host {{HOST}}

# example: `$ just switch nimbus@nimbus.fard.pl`
switch HOST *PARAMS:
  nixos-rebuild switch --flake . --target-host {{HOST}} --use-remote-sudo {{PARAMS}}

boot HOST *PARAMS:
  nixos-rebuild boot --flake . --target-host {{HOST}} --use-remote-sudo {{PARAMS}}

fetchgit *args:
  fd .nix --exec update-nix-fetchgit -v {{args}}
