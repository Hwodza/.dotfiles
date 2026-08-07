local chord = require("lib.chord")
local settings = require("lib.settings")

local main_mod = settings.main_mod

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

local scratchpads = {
  { key = "D", workspace = "discord", command = "Discord" },
  { key = "S", workspace = "spotify", command = "spotify" },
  { key = "P", workspace = "pomodoro", command = "pomodoro" },
  { key = "E", workspace = "yazi", command = "kitty --class=kitty-yazi -e yazi" },
  { key = "B", workspace = "btop", command = "kitty --class=kitty-btop -e btop" },
}

for _, scratchpad in ipairs(scratchpads) do
  hl.bind(chord(main_mod, scratchpad.key), function()
    toggle_special_workspace(scratchpad.workspace, scratchpad.command)
  end)
end

hl.bind(chord(main_mod, "P"), hl.dsp.exec_cmd("hyprshot -m region"))
