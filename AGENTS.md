# Agent Guidelines for NixOS Homeserver Configuration

**Read README.md first for project architecture, hosts setup, and commands.**

When adding guidelines here, avoid duplicating README.md.
Keep README.md as the primary source for project conventions and information.

## Environment Context

**Important**: You are currently working from WSL/development environment, NOT on the actual host machines (nimbus/fawkes). This means:

- You cannot directly run `nixos-rebuild` or system commands on the hosts
- Network connectivity to hosts may be limited or require specific routing
- Always consider that you're working outside the homeserver network context
- Test connectivity to hosts before attempting remote operations

## Code Style & Conventions

### General

- **Imports**: Group common imports at module top, use relative paths
- **Structure**: Modular configuration - one service per file when possible
- **Comments**: Avoid obvious comments. Code should be self-documenting through clear naming and structure

## Post-Edit Validation

**Always run `nix flake check` after editing .nix files** to validate configuration syntax and catch errors before deployment.
