return {
  "markdown-preview.nvim",
  ft = "markdown",
  build = function()
    vim.fn["mkdp#util#install"]()
  end,
  keys = {
    { "<leader>mp", function() require("mkdp.vim").start_preview() end, desc = "Markdown Preview" },
  },
  after = function()
    vim.g.mkdp_port = 12345
  end,
}
