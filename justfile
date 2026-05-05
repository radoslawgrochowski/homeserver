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

check-behind-remote:
  git fetch origin master && git merge-base --is-ancestor origin/master HEAD || (echo "ERROR: local branch is behind remote master. Pull first." >&2; exit 1)

# example: `$ just switch nimbus@nimbus.fard.pl`
switch HOST *PARAMS: (check-behind-remote)
  nixos-rebuild switch --flake . --target-host {{HOST}} --sudo {{PARAMS}}

boot HOST *PARAMS: (check-behind-remote)
  nixos-rebuild boot --flake . --target-host {{HOST}} --sudo {{PARAMS}}

fetchgit *args:
  fd .nix --exec update-nix-fetchgit -v {{args}}

