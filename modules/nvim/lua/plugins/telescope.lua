return {
  "telescope.nvim",
  cmd = "Telescope",
  after = function()
    require("telescope").setup({})
  end,
  keys = {
    {"<leader>sf", "<cmd>Telescope find_files<cr>", desc = "[S]earch [F]iles"},
    {"<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "[S]earch [G]rep"},
    {"<leader>sb", "<cmd>Telescope buffers<cr>", desc = "[S]earch [B]uffers"},
    {"<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "[S]earch [H]elp"},
  }
}
