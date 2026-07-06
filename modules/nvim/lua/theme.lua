local M = {}

local theme_path = vim.fn.expand("~/.local/state/theme/current/neovim.lua")

function M.load()
  if vim.fn.filereadable(theme_path) ~= 1 then
    return
  end

  local ok, err = pcall(dofile, theme_path)
  if not ok then
    vim.notify("Failed to load runtime theme: " .. tostring(err), vim.log.levels.WARN)
  end
end

vim.api.nvim_create_user_command("ThemeReload", M.load, {})

M.load()

return M
