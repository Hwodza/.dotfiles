local chord = require("lib.chord")
local paths = require("lib.paths")
local settings = require("lib.settings")

local main_mod = settings.main_mod

local reload_noctalia_state =
  "hyprctl reload && noctalia-shell ipc call state all > " .. paths.noctalia_state

hl.bind(chord(main_mod, "Q"), hl.dsp.exec_cmd(settings.terminal))
hl.bind(chord(main_mod, "X"), hl.dsp.window.close())
hl.bind(chord(main_mod, "M"), hl.dsp.exit())
hl.bind(chord(main_mod, "V"), hl.dsp.window.float())
hl.bind(chord(main_mod, "SPACE"), hl.dsp.exec_cmd(settings.app_launcher))
hl.bind(chord(main_mod, "R"), hl.dsp.exec_cmd(reload_noctalia_state))
hl.bind(chord(main_mod, "SHIFT", "S"), hl.dsp.exec_cmd("noctalia-shell ipc call sessionMenu toggle"))
hl.bind(chord(main_mod, "C"), hl.dsp.exec_cmd("noctalia-shell ipc call launcher clipboard"))
-- hl.bind(chord(main_mod, "W"), hl.dsp.exec_cmd("hyprctl hyprpaper wallpaper"))

-- SUPER + arrows/hjkl: move focus between windows in a direction.
local directional_focus_binds = {
  { "left", "left" },
  { "right", "right" },
  { "up", "up" },
  { "down", "down" },
  { "H", "left" },
  { "L", "right" },
  { "K", "up" },
  { "J", "down" },
}

for _, bind in ipairs(directional_focus_binds) do
  hl.bind(chord("SUPER", bind[1]), hl.dsp.focus({ direction = bind[2] }))
end

-- main_mod + arrows/H/L: move focus between scrolling-layout columns.
local layout_focus_binds = {
  { "left", "focus l" },
  { "right", "focus r" },
  { "H", "focus l" },
  { "L", "focus r" },
}

for _, bind in ipairs(layout_focus_binds) do
  hl.bind(chord(main_mod, bind[1]), hl.dsp.layout(bind[2]))
end

-- Lid closed: lock, then turn the screen off shortly after
hl.bind("switch:on:Lid Switch", function()
  hl.dispatch(hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
  hl.timer(function()
    hl.dispatch(hl.dsp.dpms({ action = "disable" }))
  end, { timeout = 500, type = "oneshot" })
end, { locked = true })

-- Lid opened: turn the screen back on
hl.bind("switch:off:Lid Switch", function()
  hl.dispatch(hl.dsp.dpms({ action = "enable" }))
end, { locked = true })
