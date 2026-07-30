local chord = require("lib.chord")
local settings = require("lib.settings")
local capture_static_monitors = require("lib.monitor_capture")

local main_mod = settings.main_mod
local workspace_count = settings.workspace_count

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

local function register_monitor_workspaces(monitor)
  for slot = 1, workspace_count do
    hl.workspace_rule({
      workspace = tostring(workspace_id(monitor, slot)),
      monitor = monitor.name,
      default = slot == 1,
      persistent = true,
      layout = "scrolling",
      animation = "slidevert",
    })
  end
end

-- monitors.lua makes the static hl.monitor(...) calls; capture_static_monitors
-- requires it while recording what got configured, so we can register
-- workspace rules for those monitors even before they're plugged in.
local configured_monitors = capture_static_monitors("monitors")

for _, monitor in ipairs(configured_monitors) do
  register_monitor_workspaces(monitor)
end

-- Also register for any monitors that are already active at load time, and
-- for any plugged in later.
for _, monitor in ipairs(hl.get_monitors()) do
  register_monitor_workspaces(monitor)
end

hl.on("monitor.added", register_monitor_workspaces)

-- main_mod + 1..0: jump to workspace slot. main_mod + shift + 1..0: bring the
-- focused window along.
for slot = 1, workspace_count do
  local key = slot % workspace_count

  hl.bind(chord(main_mod, key), function()
    focus_workspace_slot(slot)
  end)

  hl.bind(chord(main_mod, "SHIFT", key), function()
    move_window_to_workspace_slot(slot)
  end)
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

-- Exposed for keybinds/monitor_nav.lua and keybinds/media.lua, which need to
-- target workspaces on a specific (non-active) monitor.
return {
  workspace_id = workspace_id,
  active_workspace_slot = active_workspace_slot,
  move_window_to_workspace_id = move_window_to_workspace_id,
  focus_workspace_delta = focus_workspace_delta,
  move_window_to_workspace_delta = move_window_to_workspace_delta,
}
