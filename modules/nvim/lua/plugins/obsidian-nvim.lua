local vault = vim.fn.expand("~/Documents/The Vault")

local function trim(value)
  return vim.trim(value or "")
end

local function readable_note_id(title, dir)
  local name = trim(title)

  if name == "" then
    name = "Untitled"
  end

  for _, char in ipairs({ "/", "\\", ":", "*", "?", "\"", "<", ">", "|", "#", "^", "[", "]" }) do
    name = name:gsub(vim.pesc(char), "")
  end

  name = trim(name:gsub("%s+", " "))

  if name == "" then
    name = "Untitled"
  end

  if dir == nil then
    return name
  end

  local Path = require("obsidian.path")
  local base_dir = Path.new(dir)
  local candidate = name
  local index = 2

  while (base_dir / candidate):with_suffix(".md", true):exists() do
    candidate = string.format("%s %d", name, index)
    index = index + 1
  end

  return candidate
end

local function template_title(ctx)
  if ctx.partial_note == nil then
    return ""
  end

  return ctx.partial_note.title or ctx.partial_note.id or ""
end

return {
  "obsidian.nvim",
  event = {
    {
      event = { "BufReadPre", "BufNewFile" },
      pattern = {
        vault .. "/*.md",
        vault .. "/**/*.md",
      },
    },
  },
  after = function()
    require("obsidian").setup({
      sync = {
        enabled = true,
      },
      legacy_commands = false,
      workspaces = {
        {
          name = "personal",
          path = vault,
        },
      },
      notes_subdir = "1-RoughNotes",
      new_notes_location = "notes_subdir",
      note_id_func = readable_note_id,
      note = {
        template = "Main Template.md",
      },
      templates = {
        folder = "5-Templates",
        substitutions = {
          Title = template_title,
        },
      },
      daily_notes = {
        folder = "6-MainNotes/Daily",
        date_format = "dddd MMMM D, YYYY",
        template = "Daily Note.md",
      },
      completion = {
        blink = true,
        nvim_cmp = false,
        min_chars = 2,
      },
      picker = {
        name = "telescope.nvim",
      },
      link = {
        style = "wiki",
        format = "shortest",
        auto_update = true,
      },
      frontmatter = {
        enabled = false,
      },
      ui = {
        ignore_conceal_warn = true,
        enable = false,
      },
      callbacks = {
        enter_note = function()
          vim.opt_local.conceallevel = 2
        end,
      },
    })

    local group = vim.api.nvim_create_augroup("ObsidianVaultKeys", { clear = true })

    local function set_vault_keymaps()
      local bufname = vim.api.nvim_buf_get_name(0)
      local abs_path = vim.fn.fnamemodify(bufname, ":p")
      if abs_path == "" or abs_path:find(vault .. "/", 1, true) ~= 1 then
        return
      end

      local keys = {
        { "n", "<leader>oo", "<cmd>Obsidian<cr>", "Obsidian" },
        { "n", "<leader>on", "<cmd>Obsidian new<cr>", "Obsidian new note" },
        { "n", "<leader>oq", "<cmd>Obsidian quick_switch<cr>", "Obsidian quick switch" },
        { "n", "<leader>os", "<cmd>Obsidian search<cr>", "Obsidian search" },
        { "n", "<leader>od", "<cmd>Obsidian today<cr>", "Today's daily note" },
        { "n", "<leader>oD", "<cmd>Obsidian dailies<cr>", "List dailies" },
        { "n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", "Backlinks" },
        { "n", "<leader>ol", "<cmd>Obsidian links<cr>", "Obsidian links" },
        { "v", "<leader>ol", ":Obsidian link<cr>", "Obsidian link selection" },
        { "n", "<leader>ot", "<cmd>Obsidian template<cr>", "Obsidian template" },
        { "n", "<leader>op", "<cmd>Obsidian paste_img<cr>", "Obsidian paste image" },
      }

      for _, key in ipairs(keys) do
        vim.keymap.set(key[1], key[2], key[3], { buffer = 0, desc = key[4] })
      end
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
      group = group,
      callback = function()
        set_vault_keymaps()
      end,
    })

    set_vault_keymaps()
  end,
}
