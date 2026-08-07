# Dotfiles Context

## Nix Architecture

**dendritic pattern**
The repo's structural convention: `import-tree` recursively loads every `.nix` file under `modules/` as a flake-parts module, eliminating any central imports list.

**flake-parts module**
A `.nix` file that contributes to the flake's outputs by receiving `inputs`, `self`, etc. as arguments — the unit of organisation in this repo. Every file under `modules/` is one.
_Avoid: "module" alone (too ambiguous), "NixOS module" (conflates system modules with home modules)._

**nixosModule / homeModule / neovim module**
The three attribute namespaces used in this flake: `flake.nixosModules.<name>` (system-level), `flake.homeModules.<name>` (user-level via home-manager), and `flake.modules.neovim.<name>` (Neovim sub-modules consumed by `wrapper-modules`). Per-system derivations live under `perSystem.packages.<name>`.

**wrapped package**
A derivation produced by `wrappers.lib.wrapPackage` (Lassulus) or `wrapper-modules` (BirdeeHub) that bakes env vars, flags, or Nix module config into the binary without touching `$HOME`. `fish`, `git`, `tmux`, `neovim*`, `opencode`, and `pi` are all wrapped packages in this repo.
_Avoid: "configured package", "patched package"._

**`environment` package**
The login shell. A `writeShellApplication` that sets `EDITOR` and execs the wrapped `fish` shell, with all CLI tools (`neovimDynamic`, `tmux`, `git`, `lazygit`, `ripgrep`, `fzf`, `zoxide`, `nh`, Nix tooling, etc.) bundled as runtime inputs. Declared in `modules/features/environment.nix` and assigned as the user's shell in `modules/features/general.nix`.
_Avoid: "shell package", "user environment"._

---

## Neovim

**dynamic mode**
A Neovim build that reads its Lua config from `~/.dotfiles/modules/nvim` at runtime rather than from the Nix store. Enables live edits without rebuilding. `neovimDynamic` (the default editor) and `neovimFull` both use dynamic mode; `neovim` (static) does not.
_Avoid: "impure mode"._

**`neovimDynamic`**
The canonical editor package — dynamic mode, all LSPs (Lua, Nix, Rust, Astro). Referenced as `$EDITOR`, `$VISUAL`, and bundled into the `environment` package.

---

## Theming

**Tokyo Night Runtime**
The repo's hardcoded base16 palette (16 hex values defined in `modules/theme.nix`). Named "Runtime" because it doubles as the static fallback and the default dynamic palette.
_Avoid: "default theme", "base theme"._

**static theming**
Build-time application of the Tokyo Night palette via Stylix (GTK, cursor, and apps Stylix supports). Stylix targets for Hyprland, Neovim, rofi, and tmux are explicitly disabled in favour of dynamic theming.

**dynamic theming**
Runtime application of a palette by reading `~/.local/state/theme/current/colors.json` and writing app-specific config snippets (kitty, rofi, tmux, Neovim, Hyprland, noctalia). Hot-reloads running app instances without logout.
_Avoid: "runtime theming"._

**`theme-apply`**
The shell script that reads `colors.json` and renders the dynamic theme. Called with `--render-only` at home activation (no hot-reload) and without the flag when switching wallpapers or resetting.

**`set-wallpaper`**
The script that drives wallpaper-triggered palette changes: sets the wallpaper via awww, runs `matugen` to extract a Material You palette, writes it to `colors.json`, then calls `theme-apply`.

**`theme-reset`**
The script that restores the Tokyo Night Runtime palette by copying the default `colors.json` and calling `theme-apply`.

---

## AI Stack

**aiHarness**
The NixOS module (`modules/features/ai/aiHarness.nix`) that is the entry point for all AI tooling on the desktop. It installs `antigravity-cli` and `codex` from `llm-agents.nix` and imports `opencode`.
_Avoid: "AI module", "AI config"._

**selfHostedAI**
The NixOS module (`modules/features/ai/selfHostedAI.nix`) that runs a local LLM stack: CUDA-compiled `llama-cpp`, `llama-swap` (model-switching service on port 8080), and SearXNG (search proxy on `127.0.0.1:8888`). Active on `pc` only.
_Avoid: "local AI", "LLM stack"._

**`pi` agent**
The `pi` AI binary from `llm-agents.nix`, wrapped with `NODE_PATH` pointing to a state-directory npm install of `pi-mcp-adapter` and `@gotgenes/pi-permission-system`. Its live config files (`settings.json`, `mcp.json`, `models.json`, extensions) are symlinked from `modules/features/ai/pi/agent/` so they can be edited without rebuilding.

**live-linked config**
A config file placed via `lib.file.mkOutOfStoreSymlink` so it points directly into the dotfiles repo rather than the Nix store. Changes to the file take effect immediately. Used for the `pi` agent config, the Hyprland Lua config, and the `opencode` JSONC config.

**pi extension**
A Node.js package (typically under `~/.pi/agent/extensions/` or in a `NODE_PATH`-referenced `node_modules/`) that registers tools, commands, or hooks with the pi agent at `session_start`. Two categories: (1) npm-installed packages (currently `pi-mcp-adapter` and `@gotgenes/pi-permission-system`) and (2) source extensions placed directly under the symlinked `~/.pi/agent/extensions/` directory.

**pi plugin state dir**
The directory `~/.local/state/pi-plugins/` where `npm install` is run at home activation. Contains `node_modules/` with runtime npm packages. Its existence and contents are produced by the `installPiPlugins` home.activation script in `pi.nix`. Currently the only non-reproducible artifact in the pi setup.

**pi-mcp-adapter**
The npm package `pi-mcp-adapter` (v2.11.0) that provides MCP (Model Context Protocol) server bridging to the pi agent. It is installed into the plugin state dir via `npm install`. It has 6 direct npm dependencies (`@earendil-works/pi-ai`, `@earendil-works/pi-tui`, `@modelcontextprotocol/ext-apps`, `@modelcontextprotocol/sdk`, `open`, `recheck`, `typebox`, plus optional `zod`) and pulls in a large transitive dependency tree. The user wants a declarative, reproducible replacement.

**zero-dependency MCP extension**
A planned replacement for `pi-mcp-adapter` (documented in `.issues/pi-mcp-adapter.md`) that uses only Node.js built-ins (`child_process`, `fs`, `path`, `events`) with zero npm dependencies. It reads `mcp.json`, spawns stdio MCP servers lazily, and registers discovered tools as `mcp/<serverName>/<toolName>` in pi's tool registry. Not yet implemented — the `extensions/` directory in the dotfiles is currently empty.
_Avoid: "out-of-store symlink" (implementation detail), "mutable config"._

---

## Hosts

**`framework`**
The Framework laptop. Baseline desktop + Bluetooth with experimental battery reporting, blueman, and miniflux RSS reader. No NVIDIA, no selfHostedAI.

**`pc`**
The desktop. Baseline desktop + NVIDIA stable driver + selfHostedAI (local LLM stack). The only host running the self-hosted AI services.

**`homeLab`**
A dedicated headless home server running on an old laptop. SSH-only access with cloudflared tunnel and rclone WebDAV. Lid closed support for always-on operation.

**baseline desktop**
The set of modules every host imports: `base`, `home-manager`, `nix`, `general`, `desktop`, `ssh`. All three hosts share this baseline; `pc` additionally imports `selfHostedAI`.

---

## Secrets

**ZDR (Zero Data Retention)**
The OpenRouter API endpoint that does not log request/response data. The repo maintains two separate SOPS secrets — `OpenRouterZeroDataRetention` and `OpenRouterDataRetention` — to let opencode choose between them.
_Avoid: "ZDR key", "zero-retention key"._
