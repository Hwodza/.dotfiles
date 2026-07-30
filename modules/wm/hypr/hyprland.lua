---@module 'hl'

-- Hyprland is configured through the Lua DSL exposed as the global `hl`.
-- This file is loaded by modules/wm/hyprland.nix using Hyprland's `dofile`.
--
-- Layout:
--   lib/      shared, dependency-free helpers (paths, settings, chord, theme)
--   config/   static Hyprland settings (appearance, input, startup, rules)
--   keybinds/ everything that calls hl.bind / hl.define_submap
--
-- Monitor *hardware* configuration lives in monitors.lua (unchanged, still
-- loaded via require). keybinds/workspaces.lua requires it indirectly so it
-- can see which monitors were statically configured before registering
-- per-monitor workspace rules.

require("config.session")
require("config.appearance")
require("config.input")

require("keybinds.core")
require("keybinds.scrolling")
require("keybinds.workspaces")
require("keybinds.monitor_nav")
require("keybinds.scratchpads")
require("keybinds.media")

require("config.rules")
