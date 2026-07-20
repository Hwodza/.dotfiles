local vault = vim.fn.expand("~/Documents/The Vault")

local function is_in_vault()
  local buf_path = vim.fn.expand("%:p")
  return vim.startswith(buf_path, vault)
end

return {
  "autosave.nvim",
  ft = "markdown",
  after = function()
    require("autosave").setup({
      execution_per_filetype = {
        markdown = {
          enabled = true,
          execute = function()
            if is_in_vault() then
              return true
            end
            return false
          end,
        },
      },
      trigger = "BufWritePost",
      delay = 1000,
    })
  end,
}
