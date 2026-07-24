# theme.nix

Dual-layer theme system: declarative base via Stylix + dynamic runtime via Matugen.

**Summary inferred from config, not module-provided.** This module has no `options` with `description` fields. Add a comment at the top of `flake.theme` or add `description` fields to `mkOption` declarations if this module is meant to be reused externally.

## Namespace(s)

| Namespace | Type |
|---|---|
| `flake.theme` | Flake output — shared data |
| `flake.nixosModules.theme` | NixOS module — Stylix config |
| `flake.homeModules.theme` | Home Manager module — packages, templates, config |

## What it does

| Subsystem | What it configures |
|---|---|
| `flake.theme.base16` | Base16 Tokyo Night Runtime palette (hardcoded hex values, no `#` prefix) — source of truth for the Nix-side default |
| `flake.theme.matugenDefault` | Full Material You palette mapped from base16 — plain hex values, used as Stylix `fallback_color`, Matugen `fallback_color`, and `theme-reset` default |
| `flake.theme.noctaliaColors` | Noctalia color role mapping (`mPrimary`, `mSurface`, etc.) — flat hex values, consumed by `wm/noctalia.nix` |
| `flake.nixosModules.theme` | Imports Stylix, sets polarity to dark, base16 scheme, fonts (JetBrainsMono monospace, Ubuntu Sans serif/sansserif), font sizes |
| `flake.homeModules.theme` — packages | `set-wallpaper` (awww + matugen), `theme-reset` (matugen color), `matugen`, `awww` |
| `flake.homeModules.theme` — templates | 6 Matugen template files in `~/.config/matugen/templates/`, rendered to `~/.local/state/theme/current/` (or `~/.config/noctalia/`) on every Matugen run |
| `flake.homeModules.theme` — config | `~/.config/matugen/config.toml` (templates + post_hooks), `~/.config/theme/default/colors.json` (fallback), `~/.config/noctalia/colors.json` (default), GTK settings, awww wallpaper daemon service |
| `flake.homeModules.theme` — activation | Bootstraps `~/.local/state/theme/current/colors.json` from default palette if missing (no render step — templates run via Matugen CLI) |

## Matugen Templates

| Template | Input | Output | Post-hook |
|---|---|---|---|
| `kitty.conf` | `~/.config/matugen/templates/kitty.conf` | `~/.local/state/theme/current/kitty.conf` | `kitty @ set-colors --all` |
| `rofi.rasi` | `~/.config/matugen/templates/rofi.rasi` | `~/.local/state/theme/current/rofi.rasi` | _(none)_ |
| `tmux.conf` | `~/.config/matugen/templates/tmux.conf` | `~/.local/state/theme/current/tmux.conf` | `tmux source-file` |
| `hyprland.lua` | `~/.config/matugen/templates/hyprland.lua` | `~/.local/state/theme/current/hyprland.lua` | `hyprctl reload` |
| `neovim.lua` | `~/.config/matugen/templates/neovim.lua` | `~/.local/state/theme/current/neovim.lua` | _(none)_ |
| `noctalia-colors.json` | `~/.config/matugen/templates/noctalia-colors.json` | `~/.config/noctalia/colors.json` | _(none)_ |

All templates use Matugen's Go template syntax: `{{colors.<role>.default.hex_stripped}}` for hex values without `#`, with alpha appended directly (e.g. `{{colors.primary.default.hex_stripped}}ff`).

## Runtime Paths

| Path | Purpose |
|---|---|
| `~/.local/state/theme/current/colors.json` | Matugen-generated palette (created on first wallpaper change or reset) |
| `~/.local/state/theme/current/kitty.conf` | Rendered kitty colors, sourced by `modules/kitty.nix` via `include` |
| `~/.local/state/theme/current/rofi.rasi` | Rendered rofi colors, imported by `modules/wm/rofi.config.rasi` via `@import` |
| `~/.local/state/theme/current/hyprland.lua` | Rendered hyprland theme table, loaded by `modules/wm/hypr/hyprland.lua` via `pcall(dofile, ...)` |
| `~/.local/state/theme/current/tmux.conf` | Rendered tmux config, sourced by `modules/tmux.nix` via `configAfter` |
| `~/.local/state/theme/current/neovim.lua` | Rendered neovim colorscheme, loaded by `modules/nvim/lua/theme.lua` at startup |
| `~/.config/noctalia/colors.json` | Canonical noctia colors location (overridden by Matugen template at runtime) |

## Consumers

| Consumer | What it reads |
|---|---|
| `modules/wm/noctalia.nix` | `self.theme.noctaliaColors` (passed to `noctia-shell` wrapper) |
| `modules/features/desktop.nix` | Imports `nixosModules.theme` and `homeModules.theme` (for desktop hosts: `pc`, `framework`) |
| `modules/kitty.nix` | `~/.local/state/theme/current/kitty.conf` via `include` |
| `modules/wm/rofi.config.rasi` | `~/.local/state/theme/current/rofi.rasi` via `@import` |
| `modules/wm/hypr/hyprland.lua` | `~/.local/state/theme/current/hyprland.lua` via `pcall(dofile, ...)` |
| `modules/tmux.nix` | `~/.local/state/theme/current/tmux.conf` via `configAfter` |
| `modules/nvim/lua/theme.lua` | `~/.local/state/theme/current/neovim.lua` via `dofile` |

## How theme changes flow

1. **`set-wallpaper <image>`** → `awww img` sets wallpaper → `matugen image` reads image, generates palette, renders all 6 templates, runs post_hooks → apps update live
2. **`theme-reset`** → `matugen color <source_color> --mode dark` → same render + post_hook chain → apps update live
3. **Activation** → bootstraps `colors.json` from default palette if missing (one-time, no render)
4. **(Future)** Light/dark mode switch → `matugen color <source_color> --mode light` → same chain

## Hosts that consume this module

| Host | Import path |
|---|---|
| `pc` | `features/desktop.nix` → `nixosModules.theme` + `homeModules.theme` |
| `framework` | `features/desktop.nix` → `nixosModules.theme` + `homeModules.theme` |
| `homeLab` | _(does not import theme module)_ |

## Notes

- Stylix targets for hyprland, neovim, rofi, and tmux are `mkForce false` — Matugen templates handle rendering for these apps. Stylix only sets the base16 palette and fonts.
- The default palette (`matugenDefault`) is written to `~/.config/theme/default/colors.json` and used as Matugen's `fallback_color` and `theme-reset` source.
- Noctalia colors are written to `~/.config/noctalia/colors.json` at build time (static defaults) and at runtime (Matugen template overrides). The runtime write is a direct file copy from the template output — no symlink needed.
