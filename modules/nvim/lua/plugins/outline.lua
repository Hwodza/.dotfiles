return {
  "outline.nvim",
  keys = {
    { "<leader>l", function() require("outline").toggle() end, desc = "Toggle Outline" },
  },
  after = function()
    require("outline").setup({
      auto_open = false,
      auto_jump = false,
      keymaps = {
        show_help = "<f1>",
        jump_to_textobject = "v",
        close = "<esc>",
        collapse_all = "c",
        jump_fold_toggle = "<cr>",
        open_split = "<c-v>",
        open_vsplit = "<c-x>",
        open_tab = "<c-t>",
        scroll_down = "<c-d>",
        scroll_up = "<c-u>",
      },
    })
  end,
}
