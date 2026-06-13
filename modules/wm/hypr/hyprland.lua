---@module 'hl'

-- Hyprland is configured through the Lua DSL exposed as the global `hl`.
-- This file is loaded by modules/wm/hyprland.nix using Hyprland's `dofile`.

local terminal = os.getenv("TERMINAL") or "kitty"
local app_launcher = "rofi -show drun"
local main_mod = "ALT"
local caps_mod = "MOD2"
local workspace_count = 10

local reload_noctalia_state =
"hyprctl reload && noctalia-shell ipc call state all > /home/henry/.dotfiles/modules/wm/noctalia.json"

local function chord(...)
  local parts = { ... }
  for index, part in ipairs(parts) do
    parts[index] = tostring(part)
  end

  return table.concat(parts, " + ")
end

require("monitors")

-- --------------------------------------------------------------------------------
-- Startup
-- --------------------------------------------------------------------------------

hl.on("hyprland.start", function()
  -- Optional local daemons intentionally stay disabled here:
  -- waybar, swww-daemon, hypridle, hyprpaper, nm-applet, blueman-applet.
  hl.exec_cmd("noctalia-shell")
end)

-- --------------------------------------------------------------------------------
-- Environment
-- --------------------------------------------------------------------------------

for _, env in ipairs({
  { "XCURSOR_SIZE",                 24 },
  { "HYPRCURSOR_SIZE",              24 },
  { "ELECTRON_OZONE_PLATFORM_HINT", "auto" },
  { "TERM",                         "xterm-256color" },
  { "GDK_BACKEND",                  "x11"},
}) do
  hl.env(env[1], env[2])
end

-- --------------------------------------------------------------------------------
-- Appearance and layout
-- --------------------------------------------------------------------------------

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 0,
    border_size = 2,
    ["col.inactive_border"] = "rgba(595959aa)",
    resize_on_border = true,
    allow_tearing = false,
    layout = "scrolling",
  },
})

hl.config({
  decoration = {
    rounding = 10,
    active_opacity = 1,
    inactive_opacity = 1,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 8,
      passes = 3,
      vibrancy = 0.1696,
    },
  },
})

hl.layer_rule({
  name = "blur_noctalia_bar",
  match = {
    namespace = "^noctalia-bar-content-.*",
  },
  blur = true,
  xray = true,
})

hl.config({
  animations = {
    enabled = true,
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
    fullscreen_on_one_column = true,
    column_width = 1.0,
    focus_fit_method = 1,
    follow_min_visible = 0.0,
  },
})

hl.config({
  binds = {
    window_direction_monitor_fallback = false,
  },
})

hl.config({
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = false,
  },
})

-- --------------------------------------------------------------------------------
-- Input
-- --------------------------------------------------------------------------------

hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "caps:numlock",
    kb_rules = "",
    follow_mouse = 1,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
    },
  },
  cursor = {
    no_hardware_cursors = true,
    no_break_fs_vrr = false,
  },
})

-- --------------------------------------------------------------------------------
-- Core keybindings
-- --------------------------------------------------------------------------------

hl.bind(chord(main_mod, "Q"), hl.dsp.exec_cmd(terminal))
hl.bind(chord(main_mod, "X"), hl.dsp.window.close())
hl.bind(chord(main_mod, "M"), hl.dsp.exit())
hl.bind(chord(main_mod, "V"), hl.dsp.window.float())
hl.bind(chord(main_mod, "SPACE"), hl.dsp.exec_cmd(app_launcher))
hl.bind(chord(main_mod, "R"), hl.dsp.exec_cmd(reload_noctalia_state))
-- hl.bind(chord(main_mod, "SHIFT", "S"), hl.dsp.exec_cmd("hyprlock"))
-- hl.bind(chord(main_mod, "W"), hl.dsp.exec_cmd("hyprctl hyprpaper wallpaper"))

for _, bind in ipairs({
  { "left",  "left" },
  { "right", "right" },
  { "up",    "up" },
  { "down",  "down" },
  { "H",     "left" },
  { "L",     "right" },
  { "K",     "up" },
  { "J",     "down" },
}) do
  hl.bind(chord("SUPER", bind[1]), hl.dsp.focus({ direction = bind[2] }))
end

for _, bind in ipairs({
  { "left",  "focus l" },
  { "right", "focus r" },
  { "H",     "focus l" },
  { "L",     "focus r" },
}) do
  hl.bind(chord(main_mod, bind[1]), hl.dsp.layout(bind[2]))
end

-- --------------------------------------------------------------------------------
-- Scrolling layout helpers
-- --------------------------------------------------------------------------------

local column_width_toggles = {}

local function active_column_key()
  local window = hl.get_active_window()
  if not window then
    return nil
  end

  local workspace = window.workspace or hl.get_active_workspace()
  local monitor = window.monitor or hl.get_active_monitor()

  return table.concat({
    window.address or window.stable_id or "unknown",
    workspace and workspace.id or "unknown",
    monitor and monitor.id or "unknown",
  }, ":")
end

local function toggle_active_column_width()
  local key = active_column_key()
  if not key then
    return
  end

  -- Hyprscroll does not expose a toggle, so remember each active column state
  -- locally and alternate between half width and full width.
  if column_width_toggles[key] then
    hl.dispatch(hl.dsp.layout("colresize 1.0"))
    column_width_toggles[key] = false
  else
    hl.dispatch(hl.dsp.layout("colresize 0.5"))
    column_width_toggles[key] = true
  end
end

hl.bind(chord(main_mod, "C"), toggle_active_column_width)
hl.bind(chord(main_mod, "SHIFT", "H"), hl.dsp.layout("swapcol l"))
hl.bind(chord(main_mod, "SHIFT", "L"), hl.dsp.layout("swapcol r"))

hl.define_submap("layout", function()
  for _, bind in ipairs({
    { "H", -80, 0 },
    { "J", 0,   80 },
    { "K", 0,   -80 },
    { "L", 80,  0 },
  }) do
    hl.bind(
      bind[1],
      hl.dsp.window.resize({ x = bind[2], y = bind[3], relative = true }),
      { repeating = true }
    )
  end

  for _, bind in ipairs({
    { "SHIFT + H", "colresize -0.1" },
    { "SHIFT + L", "colresize +0.1" },
    { "SHIFT + K", "colresize -conf" },
    { "SHIFT + J", "colresize +conf" },
  }) do
    hl.bind(bind[1], hl.dsp.layout(bind[2]), { repeating = true })
  end

  for _, bind in ipairs({
    { "C", "consume" },
    { "E", "expel" },
    { "P", "promote" },
    { "5", "colresize 0.5" },
    { "0", "colresize 1.0" },
    { "A", "colresize all 1.0" },
  }) do
    hl.bind(bind[1], hl.dsp.layout(bind[2]))
  end

  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("Q", hl.dsp.submap("reset"))
end)

hl.bind(chord(main_mod, "A"), hl.dsp.submap("layout"))

-- --------------------------------------------------------------------------------
-- Workspace stack helpers
-- --------------------------------------------------------------------------------

-- Each monitor gets its own ten-workspace stack. Monitor 0 uses workspaces
-- 1-10; other monitors use offset ranges based on their Hyprland monitor id.
local function workspace_base(monitor)
  if not monitor or monitor.id == 0 then
    return 0
  end

  return (monitor.id + 1) * 100
end

local function workspace_id(monitor, slot)
  return workspace_base(monitor) + slot
end

local function workspace_slot(monitor, workspace)
  if not monitor or not workspace then
    return 1
  end

  local slot = workspace.id - workspace_base(monitor)
  if slot < 1 or slot > workspace_count then
    return 1
  end

  return slot
end

local function active_workspace_slot(monitor)
  return workspace_slot(monitor, hl.get_active_workspace(monitor) or monitor.active_workspace)
end

local function workspace_delta(monitor, delta)
  return ((active_workspace_slot(monitor) - 1 + delta) % workspace_count) + 1
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

local function focus_workspace_slot_action(slot)
  return function()
    focus_workspace_slot(slot)
  end
end

local function move_window_to_workspace_slot_action(slot)
  return function()
    move_window_to_workspace_slot(slot)
  end
end

for _, monitor in ipairs(hl.get_monitors()) do
  for slot = 1, workspace_count do
    hl.workspace_rule({
      workspace = tostring(workspace_id(monitor, slot)),
      monitor = monitor.name,
      persistent = true,
      layout = "scrolling",
      animation = "slidevert",
    })
  end
end

for slot = 1, workspace_count do
  local key = slot % workspace_count

  hl.bind(chord(main_mod, key), focus_workspace_slot_action(slot))
  hl.bind(chord(main_mod, "SHIFT", key), move_window_to_workspace_slot_action(slot))
end

hl.bind(chord(main_mod, "J"), function()
  focus_workspace_delta(1)
end)

hl.bind(chord(main_mod, "K"), function()
  focus_workspace_delta(-1)
end)

hl.bind(chord(main_mod, "SHIFT", "J"), function()
  move_window_to_workspace_delta(1)
end)

hl.bind(chord(main_mod, "SHIFT", "K"), function()
  move_window_to_workspace_delta(-1)
end)

-- --------------------------------------------------------------------------------
-- Monitor helpers
-- --------------------------------------------------------------------------------

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

  -- Pick the nearest monitor whose center is actually in the requested
  -- direction, so diagonal layouts still behave predictably.
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

local function focus_monitor_action(direction)
  return function()
    focus_monitor(direction)
  end
end

local function move_window_to_monitor_workspace_action(direction)
  return function()
    move_window_to_monitor_workspace(direction)
  end
end

for _, bind in ipairs({
  { "H", "l" },
  { "J", "d" },
  { "K", "u" },
  { "L", "r" },
}) do
  hl.bind(chord(caps_mod, bind[1]), focus_monitor_action(bind[2]))
  hl.bind(chord(caps_mod, "SHIFT", bind[1]), move_window_to_monitor_workspace_action(bind[2]))
end

-- --------------------------------------------------------------------------------
-- Scratchpads
-- --------------------------------------------------------------------------------

-- Special workspaces act like app-specific scratchpads. If a target workspace
-- has no windows yet, launch its app before toggling the workspace into view.
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

local function toggle_special_workspace_action(workspace_name, app_command)
  return function()
    toggle_special_workspace(workspace_name, app_command)
  end
end

for _, scratchpad in ipairs({
  { key = "D", workspace = "discord", command = "Discord" },
  { key = "S", workspace = "spotify", command = "spotify" },
  { key = "E", workspace = "yazi",    command = "kitty --class=kitty-yazi -e yazi" },
  { key = "B", workspace = "btop",    command = "kitty --class=kitty-btop -e btop" },
}) do
  hl.bind(
    chord(main_mod, scratchpad.key),
    toggle_special_workspace_action(scratchpad.workspace, scratchpad.command)
  )
end

hl.bind(chord(main_mod, "P"), hl.dsp.exec_cmd("hyprshot -m region"))

-- --------------------------------------------------------------------------------
-- Mouse and media
-- --------------------------------------------------------------------------------

hl.bind(chord(main_mod, "mouse_down"), function()
  focus_workspace_delta(1)
end)

hl.bind(chord(main_mod, "mouse_up"), function()
  focus_workspace_delta(-1)
end)

hl.bind(chord(main_mod, "mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(chord(main_mod, "mouse:273"), hl.dsp.window.resize(), { mouse = true })

for _, bind in ipairs({
  { "XF86AudioRaiseVolume",  "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" },
  { "XF86AudioLowerVolume",  "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" },
  { "XF86AudioMute",         "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
  { "XF86AudioMicMute",      "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
  { "XF86MonBrightnessUp",   "brightnessctl s 10%+" },
  { "XF86MonBrightnessDown", "brightnessctl s 10%-" },
  { "XF86AudioNext",         "playerctl next" },
  { "XF86AudioPause",        "playerctl play-pause" },
  { "XF86AudioPlay",         "playerctl play-pause" },
  { "XF86AudioPrev",         "playerctl previous" },
}) do
  hl.bind(bind[1], hl.dsp.exec_cmd(bind[2]), { locked = true })
end

-- --------------------------------------------------------------------------------
-- Window rules
-- --------------------------------------------------------------------------------

hl.window_rule({
  name = "suppressevent_maximi",
  match = {
    class = ".*",
  },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "nofocus",
  match = {
    class = "^$",
    title = "^$",
    xwayland = 1,
    fullscreen = 0,
  },
  no_focus = true,
})

hl.window_rule({
  name = "workspace_special_di",
  match = {
    class = "^(discord)$",
  },
  workspace = "special:discord",
})

hl.window_rule({
  name = "workspace_special_sp",
  match = {
    class = "^(spotify)$",
  },
  workspace = "special:spotify",
})

hl.window_rule({
  name = "workspace_special_ya",
  match = {
    class = "^(kitty-yazi)$",
  },
  workspace = "special:yazi",
})

hl.window_rule({
  name = "workspace_special_bt",
  match = {
    class = "^(kitty-btop)$",
  },
  workspace = "special:btop",
})
