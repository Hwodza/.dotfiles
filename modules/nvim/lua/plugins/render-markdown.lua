return {
  "render-markdown.nvim",
  ft = "markdown",
  priority = 100,
  after = function()
    require("render-markdown").setup({
      bullet = {
        enabled = true,
        icons = "mini",
      },
      heading = {
        enabled = true,
        icons = "mini",
      },
      link = {
        enable_hover = true,
      },
      code = {
        enabled = true,
        sign = false,
        virtual_text = true,
      },
    })
  end,
}
