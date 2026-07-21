require("opts")
require("keymap")
require("theme")
require('lz.n').load('plugins')

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local wrap_group = vim.api.nvim_create_augroup("SoftWrapSettings", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = wrap_group,
  pattern = { "markdown", "text", "typst" }, -- note: "md" files register as filetype "markdown"
  callback = function(args)
    local bufnr = args.buf

    -- Visual wrapping settings
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.conceallevel = 2

    -- Expression mappings: if a count precedes j/k, use logical line motion (j/k).
    -- If no count is given, use display-line motion (gj/gk) instead.
    vim.keymap.set("n", "j", function()
      return vim.v.count == 0 and "gj" or "j"
    end, { buffer = bufnr, expr = true, silent = true, desc = "Smart down (display-line aware)" })

    vim.keymap.set("n", "k", function()
      return vim.v.count == 0 and "gk" or "k"
    end, { buffer = bufnr, expr = true, silent = true, desc = "Smart up (display-line aware)" })
  end,
})

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}
