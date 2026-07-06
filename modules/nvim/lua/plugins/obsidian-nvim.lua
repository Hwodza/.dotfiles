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
    cmd = "Obsidian",
    event = {
        {
            event = { "BufReadPre", "BufNewFile" },
            pattern = {
                vault .. "/*.md",
                vault .. "/**/*.md",
            },
        },
    },
    keys = {
        { "<leader>oo", "<cmd>Obsidian<cr>", desc = "Obsidian" },
        { "<leader>on", "<cmd>Obsidian new<cr>", desc = "Obsidian new note" },
        { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian quick switch" },
        { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Obsidian search" },
        { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Obsidian today" },
        { "<leader>oD", "<cmd>Obsidian dailies<cr>", desc = "Obsidian dailies" },
        { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Obsidian backlinks" },
        { "<leader>ol", "<cmd>Obsidian links<cr>", desc = "Obsidian links" },
        { "<leader>ol", ":Obsidian link<cr>", mode = "v", desc = "Obsidian link selection" },
        { "<leader>ot", "<cmd>Obsidian template<cr>", desc = "Obsidian template" },
        { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Obsidian paste image" },
    },
    after = function()
        require("obsidian").setup({
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
            },
            callbacks = {
                enter_note = function()
                    vim.opt_local.conceallevel = 2
                end,
            },
        })
    end,
}
