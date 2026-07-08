---
name: configure-neovim-lua
description: Use when configuring Neovim, editing Lua scripts in modules/nvim/, or adding Neovim plugins.
---

# Configure Neovim (Lua)

## Context
Neovim is configured using a modern Lua-based setup, integrated via Nix modules located in `modules/nvim/`. 

## Instructions
- **File Locations**:
  - Main Nix configuration: `modules/nvim/neovim.nix`
  - Lua entry points and core options: `modules/nvim/lua/init.lua`, `opts.lua`, `keymap.lua`, `theme.lua`.
  - Plugins: Individual plugin configurations are stored in `modules/nvim/lua/plugins/` (e.g., `telescope.lua`, `blink-cmp.lua`, `obsidian-nvim.lua`).
- **Adding/Modifying Plugins**:
  - When configuring a new plugin, ensure its corresponding Nix package is declared in `neovim.nix` (if required) and its Lua setup file is created in the `plugins/` directory.
  - Follow the existing pattern of returning setup configurations or calling `require('plugin').setup({})` idiomatically.
- **Idempotency**: Ensure any autocommands or keymaps added in Lua are idempotent.