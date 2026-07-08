---
name: wm-configuration
description: Use when modifying Window Manager configurations (Hyprland, Noctalia, Wayland), window rules, or keybindings.
---

# Window Manager Configuration (Hyprland & Noctalia)

## Context
This repository configures a modern Wayland desktop environment primarily focusing on Hyprland, supplemented by Noctalia. The configurations span both Nix files and native configuration formats.

## Instructions
- **Hyprland Emphasis**:
  - The main Nix integration for Hyprland is located at `modules/wm/hyprland.nix`.
  - The raw Hyprland configuration is managed via Lua scripting at `modules/wm/hypr/hyprland.lua`. 
  - When modifying window rules, workspaces, monitors, or keybinds (binds), check whether they are managed via the native Nix module or the Lua script, and conform to the surrounding style.
- **Noctalia Context**:
  - Noctalia settings are found in `modules/wm/noctalia.nix` and its JSON configuration `modules/wm/noctalia.json`.
- **Integration**: Ensure that changes in the WM configuration play nicely with external tools (like Rofi in `rofi.config.rasi` or Waybar/Eww if present).
- **Testing**: When making changes to Wayland/Hyprland configs, be cautious of syntax errors as they can crash the user's graphical session. Double-check syntax before concluding the task.