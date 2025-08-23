# homeserver

NixOS configuration for my homeserver using flakes.

## Architecture

- **Flake-based configuration** with nixpkgs 25.05 stable
- **Two hosts**: nimbus (main server), fawkes (backup)
- **Modular structure**: Common modules shared between hosts in `common/`
- **Host-specific configs** in `nimbus/` and `fawkes/` directories
- **Services organized** as separate .nix modules with nginx reverse proxy
- **Secrets management** using agenix - never hardcode sensitive data

## Commands

Use `just` for available commands. See `justfile` for all operations.
