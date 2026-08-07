-- Builds a Hyprland bind chord string from mod/key parts, e.g.
--   chord("ALT", "SHIFT", "H") -> "ALT + SHIFT + H"
--   chord("ALT", 3)            -> "ALT + 3"

return function(...)
  local parts = { ... }
  for index, part in ipairs(parts) do
    parts[index] = tostring(part)
  end
  return table.concat(parts, " + ")
end
