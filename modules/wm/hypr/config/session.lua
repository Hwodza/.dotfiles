local paths = require("lib.paths")

-- --------------------------------------------------------------------------------
-- Startup
-- --------------------------------------------------------------------------------

hl.on("hyprland.start", function()
  -- Optional local daemons intentionally stay disabled here:
  -- waybar, hypridle, hyprpaper, nm-applet, blueman-applet.
  hl.exec_cmd("systemctl --user start awww.service")
  hl.exec_cmd(
    "jq .settings " .. paths.noctalia_state .. " > " .. paths.noctalia_settings .. " && noctalia-shell"
  )
end)

-- --------------------------------------------------------------------------------
-- Environment
-- --------------------------------------------------------------------------------

local env_vars = {
  { "XCURSOR_SIZE", 24 },
  { "HYPRCURSOR_SIZE", 24 },
  { "ELECTRON_OZONE_PLATFORM_HINT", "auto" },
  { "TERM", "xterm-256color" },
  { "GDK_BACKEND", "x11" },
}

for _, env in ipairs(env_vars) do
  hl.env(env[1], env[2])
end
