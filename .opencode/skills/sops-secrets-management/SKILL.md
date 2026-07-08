---
name: sops-secrets-management
description: Rules for sops-nix and encrypted secrets. Use ONLY when handling files in secrets/, .sops.yaml, or interacting with encryption tools.
---

# SOPS Secrets Management

## Context
This repository uses `sops-nix` to manage encrypted secrets (like API keys, passwords, or tokens). The secrets are stored in `secrets/secrets.yaml` and the rules for encryption are defined in `.sops.yaml`.

## CRITICAL AI DIRECTIVES
- **NEVER EDIT SECRETS**: You, the AI assistant, are STRICTLY FORBIDDEN from modifying `secrets/secrets.yaml` or any other encrypted file.
- **NEVER USE SOPS**: You must NEVER execute the `sops` CLI command.
- **Handling User Requests for Secrets**: If a task requires adding, removing, or changing a secret, you must stop and instruct the user to make the change manually. 
- **Nix Integration**: You may read Nix modules to understand how secrets are consumed (e.g., `config.sops.secrets.<secret-name>.path`), but you must not generate or edit the encrypted secrets files themselves.