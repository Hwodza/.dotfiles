local chord = require("lib.chord")
local settings = require("lib.settings")
local workspaces = require("keybinds.workspaces")

local caps_mod = settings.caps_mod

local function monitor_center(monitor)
  return {
    x = monitor.x + monitor.width / 2,
    y = monitor.y + monitor.height / 2,
  }
end

-- Picks the nearest monitor whose center is actually in the requested
-- direction, so diagonal layouts still behave predictably.
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
    workspaces.move_window_to_workspace_id(
      workspaces.workspace_id(monitor, workspaces.active_workspace_slot(monitor))
    )
  end
end

local monitor_direction_binds = {
  { "H", "l" },
  { "J", "d" },
  { "K", "u" },
  { "L", "r" },
}

for _, bind in ipairs(monitor_direction_binds) do
  hl.bind(chord(caps_mod, bind[1]), function()
    focus_monitor(bind[2])
  end)

  hl.bind(chord(caps_mod, "SHIFT", bind[1]), function()
    move_window_to_monitor_workspace(bind[2])
  end)
end
