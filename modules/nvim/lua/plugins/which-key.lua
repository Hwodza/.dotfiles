return {
  "which-key.nvim",
  lazy = false,
  after = function()
    local wk = require("which-key")
    wk.setup({})
    wk.add({
      { "<leader>s", group = "[S]earch" },
    })
  end,
}
