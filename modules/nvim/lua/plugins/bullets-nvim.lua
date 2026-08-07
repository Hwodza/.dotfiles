return {
  "bullets.nvim",
  after = function()
    require("bullets").setup({
      file_types = { "markdown", "text", "gitcommit" },
      renumber_on_change = true,
      delete_last_bullet = true,
      enable_in_empty_buffers = true
    })
    vim.keymap.set('n', '<leader>b', 'o- [ ] ', { desc = 'Insert check [B]ox' })
    vim.keymap.set('i', '<C-b>', '<C-o>o- [ ] ', { desc = 'Insert check [B]ox' })
  end,
}
