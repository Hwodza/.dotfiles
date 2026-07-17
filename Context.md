# Dotfiles Context

## Overview

This is a NixOS dotfiles repository for a single user (`henry`) managing multiple machines. It is structured as a **flake-parts** flake that uses the **dendritic pattern** — `import-tree` auto-discovers every `.nix` file under `modules/`, so there is no central imports list to maintain. Every `.nix` file under `modules/` is automatically loaded as a flake-parts module.

The flake targets `x86_64-linux`, `x86_64-darwin`, `aarch64-linux`, and `aarch64-darwin`, though in practice all active hosts are `x86_64-linux`.

---

## Key Technologies / Flake Inputs

| Input | Purpose |
|---|---|
| `nixpkgs` (26.05) | Primary stable channel |
| `nixpkgs-unstable` | Unstable packages (sops-nix, nix-index-database, wrappers, wrapper-modules) |
| `nixpkgs-hyprland` | Pinned unstable channel for Hyprland packages |
| `self-hosted-AI-pkgs` | Unstable channel for CUDA llama-cpp / llama-swap |
| `home-manager` (release-26.05) | User environment / dotfile management |
| `sops-nix` | Secrets management via SOPS + age keys |
| `stylix` (release-26.05) | System-wide theming from a base16 palette |
| `flake-parts` | Flake composition (the top-level framework) |
| `import-tree` | Auto-imports all `.nix` files under `modules/` |
| `wrappers` (Lassulus) | Runtime-wrapping of packages with extra env vars / flags |
| `wrapper-modules` (BirdeeHub) | Module-system wrappers for Neovim and tmux |
| `nix-index-database` | Pre-built `nix-index` database + `comma` integration |
| `llm-agents.nix` (numtide) | Provides `antigravity-cli`, `opencode`, and `pi` AI binaries |

---

## Repository Structure

```
~/.dotfiles/
├── flake.nix               # Entry point: flake-parts + import-tree
├── flake.lock
├── .sops.yaml              # age key for secrets encryption
├── secrets/
│   └── secrets.yaml        # SOPS-encrypted secrets (OpenRouter keys, searx secret, etc.)
├── pkgs/
│   └── obsidian-headless/  # Custom package: headless Obsidian (used by Neovim for obsidian-nvim)
├── .opencode/              # Opencode AI IDE configuration (skills, etc.)
└── modules/                # All NixOS/home-manager modules (auto-discovered by import-tree)
    ├── parts.nix           # flake-parts systems + per-system pkgs with allowUnfree
    ├── packages.nix        # Exposes obsidian-headless as a flake package
    ├── bash.nix            # (minimal bash config)
    ├── fish.nix            # Wrapped fish shell with custom prompt + zoxide
    ├── git.nix             # Wrapped git with hardcoded author identity
    ├── kitty.nix           # Kitty terminal — home module
    ├── tmux.nix            # Wrapped tmux via wrapper-modules
    ├── theme.nix           # Base16 palette (Tokyo Night Runtime) + dynamic theming tools
    ├── base/
    │   └── user.nix        # Defines preferences.user.{name,homeDirectory,homeStateVersion} options
    ├── features/
    │   ├── general.nix     # User account definition (wheel, networkmanager groups)
    │   ├── nix.nix         # Nix daemon config: GC, flakes, sops-nix, nix-index-database
    │   ├── ssh.nix         # SSH configuration
    │   ├── desktop.nix     # Desktop home packages + greetd/tuigreet + pipewire fonts + locales
    │   ├── environment.nix # `environment` flake package (fish shell with all CLI tools bundled)
    │   └── ai/
    │       ├── ai.nix          # (currently all commented out — historical/draft config)
    │       ├── aiHarness.nix   # Installs antigravity-cli + codex + imports opencode module
    │       ├── opencode.nix    # Opencode config: local llama-swap provider + OpenRouter + Antigravity agents
    │       ├── selfHostedAI.nix # CUDA llama-cpp + llama-swap service + SearXNG (for pc host only)
    │       ├── pi.nix          # Wraps `pi` AI agent, installs pi-mcp-adapter + pi-permission-system
    │       └── pi/agent/       # Live pi agent config files (settings.json, mcp.json, models.json, extensions/)
    ├── hosts/
    │   ├── framework/      # Framework laptop: Bluetooth, miniflux RSS, no NVIDIA
    │   ├── pc/             # Desktop PC: NVIDIA (stable driver, CUDA), selfHostedAI module
    │   └── tester/         # VM/test machine: baseline desktop config
    ├── nvim/
    │   ├── neovim.nix      # Neovim package definitions via wrapper-modules
    │   └── lua/            # Lua config (init.lua, opts.lua, keymap.lua, theme.lua, plugins/)
    └── wm/
        ├── hyprland.nix    # Hyprland home module (rofi, nwg-displays, noctalia bar)
        ├── noctalia.nix    # Noctalia status bar (custom package)
        ├── noctalia.json   # Noctalia bar config
        ├── rofi.config.rasi # Rofi launcher config
        └── hypr/
            └── hyprland.lua # Hyprland config in Lua (live-linked, not in store)
```

---

## Module / Package Naming Conventions

All modules follow the **flake-parts** attribute structure:
- `flake.nixosModules.<name>` — NixOS system modules
- `flake.homeModules.<name>` — home-manager modules
- `flake.modules.neovim.<name>` — Neovim sub-modules (consumed by `wrapper-modules`)
- `perSystem.packages.<name>` — Per-system derivations (e.g. `neovim`, `fish`, `tmux`, `environment`, `git`)

---

## Hosts

Each host lives under `modules/hosts/<name>/` with three files:

| File | Purpose |
|---|---|
| `default.nix` | Declares the `nixosConfigurations.<name>` entry in the flake |
| `hardware.nix` | Hardware scan output (filesystems, kernel modules, etc.) |
| `configuration.nix` | Host-specific NixOS settings — imports shared nixosModules |

### Host: `framework`
- Framework laptop
- Imports: `base`, `home-manager`, `nix`, `general`, `desktop`, `ssh`
- Extras: Bluetooth (experimental battery reporting), blueman, miniflux RSS reader
- `system.stateVersion = "25.11"`

### Host: `pc`
- Desktop with NVIDIA GPU
- Imports: `base`, `home-manager`, `nix`, `general`, `desktop`, `ssh`, **`selfHostedAI`**
- Extras: NVIDIA stable drivers + modesetting, CUDA-enabled btop, local LLM stack (llama-cpp + llama-swap + SearXNG)
- `system.stateVersion = "25.11"`

### Host: `tester`
- Minimal VM / test machine
- Imports: `base`, `home-manager`, `nix`, `general`, `desktop`, `ssh`
- No host-specific extras beyond baseline desktop
- `system.stateVersion = "25.11"`

---

## Key Modules

### `modules/base/user.nix`
Defines a custom NixOS option `preferences.user.{name, homeDirectory, homeStateVersion}` (defaults to `henry`, `/home/henry`, `26.05`) and sets up home-manager with `self.homeModules.default` as the user's home config. All other modules reference `config.preferences.user.name` to stay generic.

### `modules/features/environment.nix`
Defines the `environment` flake package — a `writeShellApplication` that sets `EDITOR` and launches the wrapped `fish` shell. This package is used as the user's login shell (via `general.nix`). It bundles all essential CLI tools as runtime inputs: `neovimDynamic`, `fish`, `tmux`, `git`, `yazi`, `lazygit`, `ripgrep`, `fzf`, `zoxide`, `btop`, `nh`, Nix tools (`nil`, `nixd`, `statix`, `alejandra`, `manix`), etc.

### `modules/features/desktop.nix`
The main desktop NixOS module. Imports `theme` and `aiHarness` (which brings in opencode + antigravity-cli). Sets up greetd with tuigreet launching `start-hyprland`. Configures fonts (JetBrainsMono Nerd Font, Ubuntu Sans), locales (en_US / America/New_York), and pipewire. Home-manager imports include `desktop`, `theme`, `kitty`, `hypr`, and `pi` home modules.

### `modules/theme.nix`
Two-layer theming:
1. **Static (Stylix):** A hardcoded Tokyo Night base16 palette applied at build time by Stylix to GTK, cursor, etc. Stylix targets for Hyprland, Neovim, rofi, and tmux are explicitly **disabled** in favour of the dynamic layer.
2. **Dynamic (runtime):** At home activation, `theme-apply --render-only` generates config snippets for kitty, rofi, tmux, Neovim, Hyprland, and noctalia from a `colors.json` palette stored in `~/.local/state/theme/current/`. The `set-wallpaper` script runs `matugen` on a wallpaper image to generate a new palette and then calls `theme-apply` to hot-reload all running apps without logout.

### `modules/nvim/neovim.nix`
Defines three Neovim flake packages via `wrapper-modules`:
- `neovim` — static config, Lua + Nix LSPs
- `neovimFull` — all LSPs (Lua, Nix, Rust, Astro), dynamic mode
- `neovimDynamic` — same as Full but reads config from `~/.dotfiles/modules/nvim` at runtime (used everywhere — editor, EDITOR env var)

LSPs configured: `lua_ls`, `nixd` (with `alejandra` formatter), `rust_analyzer`, `astro`.

Key plugins: `lz-n` (lazy loader), `blink-cmp` (completion), `telescope`, `oil.nvim` (file browser), `obsidian-nvim`, `codecompanion-nvim`, `gitsigns`, `lualine`, `nvim-treesitter`, `which-key`.

### `modules/wm/hyprland.nix`
Configures Hyprland via home-manager. The Hyprland package is pinned to `nixpkgs-hyprland` (unstable). The Hyprland config is a Lua file (`modules/wm/hypr/hyprland.lua`) symlinked live from the dotfiles repo — changes take effect on `hyprctl reload` without rebuilding. Includes rofi launcher and `nwg-displays` for monitor management.

### `modules/features/ai/`

| File | Status | Purpose |
|---|---|---|
| `aiHarness.nix` | **Active** | Installs `antigravity-cli` + `codex` (from `llm-agents`), imports `opencode` module |
| `opencode.nix` | **Active** | Configures opencode with: local `llama-swap` LLM provider, OpenRouter (ZDR), Antigravity (Google) models; three subagents (`thinker`, `researcher`, `architect`); SearXNG MCP server; detailed bash permission policy |
| `selfHostedAI.nix` | **Active (pc only)** | CUDA llama-cpp + llama-swap systemd service (models: `qwen2.5:0.5b`, `qwen3.6-35b-a3b`); SearXNG bound to `127.0.0.1:8888` |
| `pi.nix` | **Active** | Wraps the `pi` AI agent binary; installs `pi-mcp-adapter` and `@gotgenes/pi-permission-system` npm packages; symlinks live agent config from `modules/features/ai/pi/agent/` |
| `ai.nix` | **Commented out** | Historical/draft config (duplicate of opencode + selfHostedAI) — kept for reference |

---

## Secrets

Managed via **sops-nix** with an **age** key. The age public key is in `.sops.yaml`. The private key is expected at `/home/henry/.config/sops/age/keys.txt` on each host. Secrets are stored encrypted in `secrets/secrets.yaml`.

Secrets currently referenced:
- `OpenRouterZeroDataRetention` — OpenRouter API key (ZDR endpoint)
- `OpenRouterDataRetention` — OpenRouter API key (standard endpoint)
- `searx` — SearXNG secret key (pc only)

---

## Custom Packages (`pkgs/`)

### `pkgs/obsidian-headless`
A headless (no-GUI) build of Obsidian used by `obsidian-nvim` to index and search vault contents from within Neovim. Exposed as `packages.obsidian-headless` in the flake and bundled as a runtime input for all Neovim builds.

---

## Wrapped Packages Pattern

Several packages are wrapped using `wrappers` (Lassulus) or `wrapper-modules` (BirdeeHub) to bake in configuration without polluting `$HOME`:

| Package | Wrapper | Notes |
|---|---|---|
| `fish` | `wrappers.lib.wrapPackage` | Loads custom prompt config + zoxide init via `-C source ...` flag |
| `git` | `wrappers.lib.wrapPackage` | Bakes in `GIT_AUTHOR_NAME`/`EMAIL` env vars |
| `tmux` | `wrapper-modules` tmux wrapper | Full tmux config as module options; plugins; theme hot-reload via `source-file` |
| `neovim*` | `wrapper-modules` neovim wrapper | LSP modules composed declaratively; dynamic vs static config directory |
| `opencode` | `pkgs.writeShellScriptBin` | Injects `OPENROUTER_*` secrets from `/run/secrets/` before exec |
| `pi` | `pkgs.symlinkJoin` + `makeWrapper` | Sets `NODE_PATH` to the plugins state directory |

---

## Theming System Summary

1. **Palette:** Tokyo Night Runtime (base16, 16 colors) defined in `theme.nix`
2. **Static application (build time):** Stylix applies the palette to GTK, cursor, and apps it supports
3. **Dynamic application (runtime):** `theme-apply` reads `~/.local/state/theme/current/colors.json` and writes config snippets for kitty, rofi, tmux, Neovim, Hyprland, and noctalia. Hot-reloads running instances.
4. **Wallpaper-driven theming:** `set-wallpaper <image>` runs `matugen` to extract a Material You palette from the image, writes it to `colors.json`, then calls `theme-apply`.
5. **Reset:** `theme-reset` restores the default Tokyo Night palette.

---

## Deployment

Hosts are rebuilt with `nh os switch` (or `nixos-rebuild switch`), which reads `NH_FLAKE=/home/henry/dotfiles` (set in `desktop.nix`). Note: `NH_FLAKE` points to `~/dotfiles` (a symlink to `~/.dotfiles`) rather than the dotfiles directory directly.
