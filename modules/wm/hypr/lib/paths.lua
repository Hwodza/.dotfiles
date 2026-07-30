-- Every path in the config is derived from $HOME here, so nothing below
-- breaks when the config runs under a different user account.

local home = os.getenv("HOME") or "/home/henry"
local wm_dir = home .. "/.dotfiles/modules/wm"

return {
  home = home,
  noctalia_state = wm_dir .. "/noctalia.json",
  noctalia_settings = home .. "/.config/noctalia/settings.json",
  theme_file = home .. "/.local/state/theme/current/hyprland.lua",
}
