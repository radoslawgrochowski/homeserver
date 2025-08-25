# Agent Guidelines for NixOS Homeserver Configuration

**Read README.md first for project architecture, hosts setup, and commands.**

When adding guidelines here, avoid duplicating README.md.
Keep README.md as the primary source for project conventions and information.

## Environment Context

**Important**: You are currently working from WSL/development environment, NOT on the actual host machines (nimbus/fawkes). This means:

- You cannot directly run `nixos-rebuild` or system commands on the hosts
- Use `just switch <HOST>` commands for remote rebuilds (requires SSH access)
- Network connectivity to hosts may be limited or require specific routing
- Always consider that you're working outside the homeserver network context
- Test connectivity to hosts before attempting remote operations

## Code Style & Conventions

- **Imports**: Group common imports at module top, use relative paths
- **Structure**: Modular configuration - one service per file when possible
