return {
  "mini.ai",
  lazy = false,
  after = function()
    require("mini.ai").setup({
      n_lines = 50,
    })
  end,
}
