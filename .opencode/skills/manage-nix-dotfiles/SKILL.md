---
name: manage-nix-dotfiles
description: Use when managing Nix and NixOS configurations, handling dendritic imports, or rebuilding the system.
---

# Manage Nix Dotfiles

## Context
This repository uses a modular Nix and NixOS configuration driven by `flake-parts` and `import-tree`. The configuration is highly dendritic, meaning `import-tree` automatically evaluates and imports modules located recursively within the `./modules` directory.

## Instructions
- **Structure**: All main logic is broken down into small, modular files under `./modules/`. When adding a new feature or application, create a self-contained module in the appropriate subdirectory rather than bloating existing files.
- **Flake Structure**: The `flake.nix` uses `flake-parts`. System definitions are typically defined in `./modules/hosts/<hostname>/default.nix`.
- **System Rebuilds**:
  - **NEVER** run `nixos-rebuild switch` or `home-manager switch` yourself. The user is strictly responsible for applying system changes.
  - You can verify syntax or evaluate the flake if needed (e.g., `nix flake check` or `nix-instantiate --parse`), but do not apply the configuration to the live system.
- **Formatting**: Respect existing formatting conventions in Nix files (usually maintained by formatters like `alejandra` or `nixpkgs-fmt`).