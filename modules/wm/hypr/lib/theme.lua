-- Fallback colors, used until (or unless) the theme daemon writes a runtime
-- theme file. Any keys present in the runtime file override these defaults.

local paths = require("lib.paths")

local theme = {
  active_border = "rgba(7aa2f7ff)",
  inactive_border = "rgba(565f89aa)",
  shadow = "rgba(000000ee)",
}

local ok, loaded_theme = pcall(dofile, paths.theme_file)
if ok and type(loaded_theme) == "table" then
  for key, value in pairs(loaded_theme) do
    theme[key] = value
  end
end

return theme
