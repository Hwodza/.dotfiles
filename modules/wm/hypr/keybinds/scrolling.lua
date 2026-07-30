local chord = require("lib.chord")
local settings = require("lib.settings")

local main_mod = settings.main_mod

-- Hyprscroll does not expose a "toggle column width" dispatcher, so we
-- remember each active column's state locally and alternate between half
-- width and full width.
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

  if column_width_toggles[key] then
    hl.dispatch(hl.dsp.layout("colresize 1.0"))
    column_width_toggles[key] = false
  else
    hl.dispatch(hl.dsp.layout("colresize 0.5"))
    column_width_toggles[key] = true
  end
end

hl.bind(chord(main_mod, "T"), toggle_active_column_width)
hl.bind(chord(main_mod, "SHIFT", "H"), hl.dsp.layout("swapcol l"))
hl.bind(chord(main_mod, "SHIFT", "L"), hl.dsp.layout("swapcol r"))

hl.define_submap("layout", function()
  local move_binds = {
    { "H", -80, 0 },
    { "J", 0, 80 },
    { "K", 0, -80 },
    { "L", 80, 0 },
  }

  for _, bind in ipairs(move_binds) do
    hl.bind(
      bind[1],
      hl.dsp.window.resize({ x = bind[2], y = bind[3], relative = true }),
      { repeating = true }
    )
  end

  local resize_binds = {
    { "SHIFT + H", "colresize -0.1" },
    { "SHIFT + L", "colresize +0.1" },
    { "SHIFT + K", "colresize -conf" },
    { "SHIFT + J", "colresize +conf" },
  }

  for _, bind in ipairs(resize_binds) do
    hl.bind(bind[1], hl.dsp.layout(bind[2]), { repeating = true })
  end

  local action_binds = {
    { "C", "consume" },
    { "E", "expel" },
    { "P", "promote" },
    { "5", "colresize 0.5" },
    { "0", "colresize 1.0" },
    { "A", "colresize all 1.0" },
  }

  for _, bind in ipairs(action_binds) do
    hl.bind(bind[1], hl.dsp.layout(bind[2]))
  end

  hl.bind("escape", hl.dsp.submap("reset"))
  hl.bind("Q", hl.dsp.submap("reset"))
end)

hl.bind(chord(main_mod, "A"), hl.dsp.submap("layout"))
