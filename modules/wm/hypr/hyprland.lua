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

hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 5,
  bezier = "default",
  style = "slidevert",
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


-- Sets Alt key as main modifer
local mainMod = "ALT"
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

-- Move focus with super + arrow keys or vim motions, also allow for mainMod right/left H/L

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

-- Switch per-monitor workspace stacks with mainMod + [0-9].
-- Workspace 1 is the top of each stack, 10 is the bottom.
local workspaceCount = 10

local function workspace_prefix(monitor)
  return ((monitor and monitor.id or 0) + 1) * 100
end

local function workspace_id(monitor, slot)
  return workspace_prefix(monitor) + slot
end

local function workspace_slot(monitor, workspace)
  if not monitor or not workspace then
    return 1
  end

  local slot = workspace.id - workspace_prefix(monitor)
  if slot < 1 or slot > workspaceCount then
    return 1
  end

  return slot
end

local function active_workspace_slot(monitor)
  return workspace_slot(monitor, hl.get_active_workspace(monitor) or monitor.active_workspace)
end

local function workspace_delta(monitor, delta)
  return ((active_workspace_slot(monitor) - 1 + delta) % workspaceCount) + 1
end

local function focus_workspace_id(workspace)
  hl.dispatch(hl.dsp.focus({
    workspace = workspace,
    on_current_monitor = true,
  }))
end

local function focus_workspace_slot(slot)
  local monitor = hl.get_active_monitor()
  if monitor then
    focus_workspace_id(workspace_id(monitor, slot))
  end
end

local function focus_workspace_delta(delta)
  local monitor = hl.get_active_monitor()
  if monitor then
    focus_workspace_id(workspace_id(monitor, workspace_delta(monitor, delta)))
  end
end

local function move_window_to_workspace_id(workspace)
  hl.dispatch(hl.dsp.window.move({
    workspace = workspace,
    follow = true,
  }))
end

local function move_window_to_workspace_slot(slot)
  local monitor = hl.get_active_monitor()
  if monitor then
    move_window_to_workspace_id(workspace_id(monitor, slot))
  end
end

local function move_window_to_workspace_delta(delta)
  local monitor = hl.get_active_monitor()
  if monitor then
    move_window_to_workspace_id(workspace_id(monitor, workspace_delta(monitor, delta)))
  end
end

for _, monitor in ipairs(hl.get_monitors()) do
  for slot = 1, workspaceCount do
    hl.workspace_rule({
      workspace = tostring(workspace_id(monitor, slot)),
      monitor = monitor.name,
      persistent = true,
      layout = "scrolling",
      animation = "slidevert",
    })
  end
end

for slot = 1, workspaceCount do
  local key = slot % workspaceCount

  hl.bind(mainMod .. " + " .. key, function()
    focus_workspace_slot(slot)
  end)

  hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. key, function()
    move_window_to_workspace_slot(slot)
  end)
end

hl.bind(mainMod .. " + " .. "J", function()
  focus_workspace_delta(1)
end)

hl.bind(mainMod .. " + " .. "K", function()
  focus_workspace_delta(-1)
end)

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "J", function()
  move_window_to_workspace_delta(1)
end)

hl.bind(mainMod .. " + " .. "SHIFT" .. " + " .. "K", function()
  move_window_to_workspace_delta(-1)
end)

-- Move between monitors with CapsLock vim motions.

local function monitor_center(monitor)
  return {
    x = monitor.x + monitor.width / 2,
    y = monitor.y + monitor.height / 2,
  }
end

local function monitor_in_direction(direction)
  local active = hl.get_active_monitor()
  if not active then
    return nil
  end

  local active_center = monitor_center(active)
  local best_monitor = nil
  local best_score = nil

  for _, monitor in ipairs(hl.get_monitors()) do
    if monitor.id ~= active.id then
      local center = monitor_center(monitor)
      local dx = center.x - active_center.x
      local dy = center.y - active_center.y
      local primary = nil
      local secondary = nil

      if direction == "l" then
        primary = -dx
        secondary = dy
      elseif direction == "r" then
        primary = dx
        secondary = dy
      elseif direction == "u" then
        primary = -dy
        secondary = dx
      elseif direction == "d" then
        primary = dy
        secondary = dx
      end

      if primary and primary > 0 then
        local score = primary * primary + secondary * secondary
        if not best_score or score < best_score then
          best_monitor = monitor
          best_score = score
        end
      end
    end
  end

  return best_monitor
end

local function focus_monitor(direction)
  local monitor = monitor_in_direction(direction)
  if monitor then
    hl.dispatch(hl.dsp.focus({ monitor = monitor.name }))
  end
end

local function move_window_to_monitor_workspace(direction)
  local monitor = monitor_in_direction(direction)
  if monitor then
    move_window_to_workspace_id(workspace_id(monitor, active_workspace_slot(monitor)))
  end
end

hl.bind(CAP .. " + " .. "H", function()
  focus_monitor("l")
end)

hl.bind(CAP .. " + " .. "J", function()
  focus_monitor("d")
end)

hl.bind(CAP .. " + " .. "K", function()
  focus_monitor("u")
end)

hl.bind(CAP .. " + " .. "L", function()
  focus_monitor("r")
end)

hl.bind(CAP .. " + " .. "SHIFT" .. " + " .. "H", function()
  move_window_to_monitor_workspace("l")
end)

hl.bind(CAP .. " + " .. "SHIFT" .. " + " .. "J", function()
  move_window_to_monitor_workspace("d")
end)

hl.bind(CAP .. " + " .. "SHIFT" .. " + " .. "K", function()
  move_window_to_monitor_workspace("u")
end)

hl.bind(CAP .. " + " .. "SHIFT" .. " + " .. "L", function()
  move_window_to_monitor_workspace("r")
end)

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

-- Scroll through the active monitor's workspace stack with mainMod + scroll

hl.bind(mainMod .. " + " .. "mouse_down", function()
  focus_workspace_delta(1)
end)

hl.bind(mainMod .. " + " .. "mouse_up", function()
  focus_workspace_delta(-1)
end)

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
