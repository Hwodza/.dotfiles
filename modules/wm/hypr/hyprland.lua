---@module 'hl'

-- https://wiki.hyprland.org/Configuring/


--##################

--## MY PROGRAMS ###

--##################

-- See https://wiki.hyprland.org/Configuring/Keywords/

-- Set programs that you use

local terminal = os.getenv("TERMINAL") or "kitty"

local fileManager = terminal .. " -e yazi"

local menu = "rofi -show drun"

require("monitors")
--################

--## AUTOSTART ###

--################


--############################

--## ENVIRONMENT VARIABLES ###

--############################

-- See https://wiki.hyprland.org/Configuring/Environment-variables/

hl.env("XCURSOR_SIZE", 24)

hl.env("HYPRCURSOR_SIZE", 24)

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

hl.env("TERM", "xterm-256color")

--####################

--## LOOK AND FEEL ###

--####################

-- Refer to https://wiki.hyprland.org/Configuring/Variables/

-- https://wiki.hyprland.org/Configuring/Variables/#general

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 0,
    border_size = 2,
    -- https://wiki.hyprland.org/Configuring/Variables/#variable-types for info about colors
    -- ["col.active_border"] = "rgba(33ccffee) rgba(00ff99ee) 45deg",
    ["col.inactive_border"] = "rgba(595959aa)",
    -- Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = true,
    -- Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
    allow_tearing = false,
    layout = "scrolling",
  },
})

-- https://wiki.hyprland.org/Configuring/Variables/#decoration

hl.config({
  decoration = {
    rounding = 10,
    -- Change transparency of focused and unfocused windows
    active_opacity = 1,
    inactive_opacity = 1,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    -- https://wiki.hyprland.org/Configuring/Variables/#blur
    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      vibrancy = 0.1696,
    },
  },
})

-- https://wiki.hyprland.org/Configuring/Variables/#animations

hl.config({
  animations = {
    enabled = true,
    -- Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
  },
})


hl.config({
  scrolling = {
    column_width = 1.0,
  },
})

-- See https://wiki.hyprland.org/Configuring/Master-Layout/ for more

-- hl.config({
--   master = {
--     new_status = "master",
--   },
-- })

-- https://wiki.hyprland.org/Configuring/Variables/#misc

hl.config({
  misc = {
    force_default_wallpaper = 0,
    -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false,
    -- If true disables the random hyprland logo / anime girl background. :(
  },
})

--############

--## INPUT ###

--############

-- https://wiki.hyprland.org/Configuring/Variables/#input

hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "caps:numlock",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,
    -- -1.0 - 1.0, 0 means no modification.
    touchpad = {
      natural_scroll = true,
      -- tap_to_click = true,
    },
  },
})

-- https://wiki.hyprland.org/Configuring/Variables/#gestures

-- gestures {

-- 		workspace_swipe = false

-- }

-- Example per-device config

-- See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more

-- hl.config({
--     device = {
--         name = "epic-mouse-v1",
--         sensitivity = -0.5,
--     },
-- })
-- NOTE: Section 'device' may be a plugin or custom section; verify the output

--##################

--## KEYBINDINGS ###

--##################

-- See https://wiki.hyprland.org/Configuring/Keywords/

-- $mainMod = SUPER # Sets "Windows" key as main modifier

local mainMod = "ALT"

-- Sets Alt key as main modifer

local CAP = "MOD2"

-- Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

hl.bind(mainMod .. " + " .. "Q", hl.dsp.exec_cmd(terminal))

hl.bind(mainMod .. " + " .. "X", hl.dsp.window.close())

hl.bind(mainMod .. " + " .. "M", hl.dsp.exit())

hl.bind(mainMod .. " + " .. "V", hl.dsp.window.float())

hl.bind(mainMod .. " + " .. "SPACE", hl.dsp.exec_cmd("rofi -show drun"))

hl.bind(mainMod .. " + " .. "R",
  hl.dsp.exec_cmd("hyprctl reload && noctalia-shell ipc call state all > /home/henry/.dotfiles/modules/wm/noctalia.json"))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "S", hl.dsp.exec_cmd("hyprlock"))

hl.bind(mainMod .. " + " .. "W", hl.dsp.exec_cmd("hyprctl hyprpaper wallpaper"))

-- Move focus with mainMod + arrow keys

hl.bind("SUPER" .. " + " .. "left", hl.dsp.focus({ direction = "left" }))

hl.bind("SUPER" .. " + " .. "right", hl.dsp.focus({ direction = "right" }))

hl.bind("SUPER" .. " + " .. "up", hl.dsp.focus({ direction = "up" }))

hl.bind("SUPER" .. " + " .. "down", hl.dsp.focus({ direction = "down" }))

hl.bind("SUPER" .. " + " .. "H", hl.dsp.focus({ direction = "left" }))

hl.bind("SUPER" .. " + " .. "L", hl.dsp.focus({ direction = "right" }))

hl.bind("SUPER" .. " + " .. "K", hl.dsp.focus({ direction = "up" }))

hl.bind("SUPER" .. " + " .. "J", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + " .. "left", hl.dsp.focus({ direction = "left" }))

hl.bind(mainMod .. " + " .. "right", hl.dsp.focus({ direction = "right" }))

hl.bind(mainMod .. " + " .. "H", hl.dsp.focus({ direction = "left" }))

hl.bind(mainMod .. " + " .. "L", hl.dsp.focus({ direction = "right" }))

-- Switch workspaces with mainMod + [0-9]

hl.bind(mainMod .. " + " .. 1, hl.dsp.focus({ workspace = 1 }))

hl.bind(mainMod .. " + " .. 2, hl.dsp.focus({ workspace = 2 }))

hl.bind(mainMod .. " + " .. 3, hl.dsp.focus({ workspace = 3 }))

hl.bind(mainMod .. " + " .. 4, hl.dsp.focus({ workspace = 4 }))

hl.bind(mainMod .. " + " .. 5, hl.dsp.focus({ workspace = 5 }))

hl.bind(mainMod .. " + " .. 6, hl.dsp.focus({ workspace = 6 }))

hl.bind(mainMod .. " + " .. 7, hl.dsp.focus({ workspace = 7 }))

hl.bind(mainMod .. " + " .. 8, hl.dsp.focus({ workspace = 8 }))

hl.bind(mainMod .. " + " .. 9, hl.dsp.focus({ workspace = 9 }))

hl.bind(mainMod .. " + " .. 0, hl.dsp.focus({ workspace = 10 }))

-- hl.bind(mainMod .. " + " .. "K", hl.dsp.focus({ workspace = (hl.get_active_workspace().id + 9) % 10 }))
-- hl.bind(mainMod .. " + " .. "J", hl.dsp.focus({ workspace = (hl.get_active_workspace().id + 11) % 10 }))

-- hl.bind(mainMod .. "+ SHIFT + " .. "k", hl.dsp.window.move({ workspace = (hl.get_active_workspace().id + 9) % 10 }))
-- Switch workspaces with workspace2d.sh

-- for i = 1, 10 do
--   local key = i % 10
--   hl.bind(mainMod .. "+" .. key, hl.dsp.focus({ workspace = i }))
--   hl.bind(mainMod .. "+ SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
-- end

-- Switch workspaces with workspace2d.sh

-- Navigate workspaces in 2D
-- local matrixSize = 8
-- local maxScreens = 10
-- for i = 1, 8 do
--   local navKey = { "Left", "Up", "Right", "Down", "H", "K", "L", "J" }
--   local workspace = hl.get_active_workspace().id
--   local x = workspace % matrixSize
--   local y = workspace // matrixSize
--   if i % 2 == 0 then
--     hl.animation({ leaf = "workspaces", enabled = true})
--   end
--   -- local x = hl.get_active_workspace() % matrixSize
--   -- local x = hl.get_active_workspace() % matr
-- end

-- hl.bind(mainMod .. " + " .. "H", hl.dsp.exec_cmd("workspace2d left"))
--
-- hl.bind(mainMod .. " + " .. "L", hl.dsp.exec_cmd("workspace2d right"))
--
-- hl.bind(mainMod .. " + " .. "K", hl.dsp.exec_cmd("workspace2d up"))
--
-- hl.bind(mainMod .. " + " .. "J", hl.dsp.exec_cmd("workspace2d down"))

-- Move windows instead of focus

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "H", hl.dsp.exec_cmd("workspace2d move_left"))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "L", hl.dsp.exec_cmd("workspace2d move_right"))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "K", hl.dsp.exec_cmd("workspace2d move_up"))

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "J", hl.dsp.exec_cmd("workspace2d move_down"))

-- Apply moves to all monitors

hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "H", hl.dsp.exec_cmd("workspace2d left all"))

hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "L", hl.dsp.exec_cmd("workspace2d right all"))

hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "K", hl.dsp.exec_cmd("workspace2d up all"))

hl.bind(mainMod .. " + " .. "CTRL" .. " + " .. "J", hl.dsp.exec_cmd("workspace2d down all"))

-- Sync all monitors

hl.bind(mainMod .. " + " .. "CTRL + SHIFT" .. " + " .. "H", hl.dsp.exec_cmd("workspace2d left all sync"))

hl.bind(mainMod .. " + " .. "CTRL + SHIFT" .. " + " .. "L", hl.dsp.exec_cmd("workspace2d right all sync"))

hl.bind(mainMod .. " + " .. "CTRL + SHIFT" .. " + " .. "K", hl.dsp.exec_cmd("workspace2d up all sync"))

hl.bind(mainMod .. " + " .. "CTRL + SHIFT" .. " + " .. "J", hl.dsp.exec_cmd("workspace2d down all sync"))

-- Monitor focus keybinds

-- hl.bind(CAP .. " + " .. "H", hl.dsp.focus({direction = "left"}))
--
-- hl.bind(CAP .. " + " .. "J", hl.dsp.focus({ direction = "down" }))
--
-- hl.bind(CAP .. " + " .. "K", hl.dsp.focus({ direction = "up" }))
--
-- hl.bind(CAP .. " + " .. "L", hl.dsp.focus({ direction = "left" }))
--
-- -- Monitor Move window keybinds
--
-- hl.bind(CAP .. " + " .. "SHIFT" .. " + " .. "H", { direction = "left" })
--
-- hl.bind(CAP .. " + " .. "SHIFT" .. " + " .. "J", { direction = "down" })
--
-- hl.bind(CAP .. " + " .. "SHIFT" .. " + " .. "K", { direction = "up" })
--
-- hl.bind(CAP .. " + " .. "SHIFT" .. " + " .. "L", { direction = "right" })

-- Screenshot a region

hl.bind(mainMod .. " + " .. "P", hl.dsp.exec_cmd("hyprshot -m region"))

-- Example special workspace (scratchpad)

-- bind = $mainMod, S, togglespecialworkspace, magic

-- bind = $mainMod SHIFT, S, movetoworkspace, special:magic

-- Special workspaces
local function toggle_special_workspace(workspace_name, app_command)
  local active_ws = hl.get_active_workspace()
  if active_ws ~= nil and active_ws.name == "special:" .. workspace_name then
    hl.dispatch(hl.dsp.workspace.toggle_special(workspace_name))
    return
  end

  local ws_exists = false
  for _, ws in ipairs(hl.get_workspaces()) do
    if ws.name == "special:" .. workspace_name and ws.windows > 0 then
      ws_exists = true
      break
    end
  end

  if not ws_exists then
    hl.dispatch(hl.dsp.exec_cmd("/usr/bin/env sh -c '" .. app_command .. "'"))
  end
  hl.dispatch(hl.dsp.workspace.toggle_special(workspace_name))
end

hl.bind(mainMod .. " + " .. "D", function()
  toggle_special_workspace("discord", "Discord")
end)

hl.bind(mainMod .. " + " .. "S", function()
  toggle_special_workspace("spotify", "spotify")
end)

hl.bind(mainMod .. " + " .. "E", function()
  toggle_special_workspace("yazi", "kitty --class=kitty-yazi -e yazi")
end)

hl.bind(mainMod .. " + " .. "B", function()
  toggle_special_workspace("btop", "kitty --class=kitty-btop -e btop")
end)

-- Scroll through existing workspaces with mainMod + scroll

hl.bind(mainMod .. " + " .. "mouse_down", hl.dsp.focus({ workspace = "e+1" }))

hl.bind(mainMod .. " + " .. "mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging

hl.bind(mainMod .. " + " .. "mouse:272", hl.dsp.window.drag(), { mouse = true })

hl.bind(mainMod .. " + " .. "mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true })

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true })

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true })

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true })

-- Requires playerctl

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })

hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--#############################

--## WINDOWS AND WORKSPACES ###

--#############################

-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

-- See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

-- Example windowrule v1

-- windowrule = float, ^(kitty)$

-- Example windowrule v2

-- windowrulev2 = float,class:^(kitty)$,title:^(kitty)$

-- Ignore maximize requests from apps. You'll probably like this.

hl.window_rule({
  name           = "suppressevent_maximi",
  match          = {
    class = ".*",
  },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland

hl.window_rule({
  name     = "nofocus",
  match    = {
    class = "^$",
    title = "^$",
    xwayland = 1,
    -- floating = 1,
    fullscreen = 0,
    -- pinned = 0,
  },
  no_focus = true,
})

-- Make Firefox open to workspace 2

-- windowrulev2 = workspace 2, class:firefox

-- Make Discord open to workspace 3

-- windowrulev2 = workspace 3, class:discord

-- Make Spotify open to workspace 4

-- windowrulev2 = workspace 4, class:spotify

-- Make Obsidian open to workspace 6

-- windowrulev2 = workspace 6, class:obsidian

-- Special workspace rules

hl.window_rule({
  name      = "workspace_special_di",
  match     = {
    class = "^(discord)$",
  },
  workspace = "special:discord",
})

hl.window_rule({
  name      = "workspace_special_sp",
  match     = {
    class = "^(spotify)$",
  },
  workspace = "special:spotify",
})

hl.window_rule({
  name      = "workspace_special_ya",
  match     = {
    class = "^(kitty-yazi)$",
  },
  workspace = "special:yazi",
})

hl.window_rule({
  name      = "workspace_special_bt",
  match     = {
    class = "^(kitty-btop)$",
  },
  workspace = "special:btop",
})

-- Autostart
hl.on("hyprland.start", function()
  -- hl.exec_cmd("waybar")
  -- hl.exec_cmd("swww-daemon")
  -- hl.exec_cmd("hypridle")
  -- hl.exec_cmd("hyprpaper")
  -- hl.exec_cmd("nm-applet")
  -- hl.exec_cmd("blueman-applet")
  hl.exec_cmd("noctalia-shell")
end)
