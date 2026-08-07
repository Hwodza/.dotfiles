local chord = require("lib.chord")
local settings = require("lib.settings")
local workspaces = require("keybinds.workspaces")

local main_mod = settings.main_mod

hl.bind(chord(main_mod, "mouse_down"), function()
  workspaces.focus_workspace_delta(1)
end)

hl.bind(chord(main_mod, "mouse_up"), function()
  workspaces.focus_workspace_delta(-1)
end)

hl.bind(chord(main_mod, "mouse:272"), hl.dsp.window.drag(), { mouse = true })
hl.bind(chord(main_mod, "mouse:273"), hl.dsp.window.resize(), { mouse = true })

local media_keys = {
  { "XF86AudioRaiseVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+" },
  { "XF86AudioLowerVolume", "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" },
  { "XF86AudioMute", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
  { "XF86AudioMicMute", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" },
  { "XF86MonBrightnessUp", "brightnessctl s 10%+" },
  { "XF86MonBrightnessDown", "brightnessctl s 10%-" },
  { "XF86AudioNext", "playerctl next" },
  { "XF86AudioPause", "playerctl play-pause" },
  { "XF86AudioPlay", "playerctl play-pause" },
  { "XF86AudioPrev", "playerctl previous" },
}

for _, bind in ipairs(media_keys) do
  hl.bind(bind[1], hl.dsp.exec_cmd(bind[2]), { locked = true })
end
